import AppKit
import Foundation

@MainActor
final class MinecraftStudioModel: ObservableObject {
    private enum DefaultsKey {
        static let selectedServerPath = "minecraftServerStudio.selectedServerPath"
    }

    @Published var selectedPanel: StudioPanel = .commandCenter
    @Published var serverChoices: [String] = []
    @Published var selectedServerPath: String = ""
    @Published var agents: [StudioAgentProfile] = []
    @Published var selectedAgentID: UUID?
    @Published var agentDraftName: String = ""
    @Published var agentDraftRole: String = ""
    @Published var agentDraftStylePreset: String = ""
    @Published var agentDraftPromptSeed: String = ""
    @Published var agentDraftBehaviorNotes: String = ""
    @Published var agentDraftMemoryEnabled = true
    @Published var jobs: [StudioBuildJob] = []
    @Published var jobDraftTitle: String = ""
    @Published var jobDraftPrompt: String = ""
    @Published var jobDraftStyle: String = ""
    @Published var newServerName: String = "creative-sandbox"
    @Published var newServerPort: String = "25565"
    @Published var newServerMemoryMB: String = "4096"
    @Published var newServerCloneMode: StudioPluginCloneMode = .creativeTooling
    @Published private(set) var memoryEntries: [StudioMemoryEntry] = []
    @Published var autoMemoryEnabled = true
    @Published private(set) var snapshot: ServerSnapshot = .empty
    @Published private(set) var headline: String = "Scanning for Paper servers"
    @Published private(set) var subheadline: String = "Point it at a local server and use the menu bar to inspect the stack."
    @Published private(set) var isRefreshing = false
    @Published private(set) var actionMessage: String = ""
    @Published private(set) var memoryStatusMessage: String = ""
    @Published private(set) var provisioningMessage: String = ""
    @Published private(set) var clipboardMessage: String = ""

    private let defaults = UserDefaults.standard
    private let persistence = StudioPersistence()
    private let provisioner = ServerProvisioner()
    private nonisolated(unsafe) var refreshTimer: Timer?

    init() {
        selectedServerPath = defaults.string(forKey: DefaultsKey.selectedServerPath) ?? ""
        loadState()
        scheduleAutoRefresh()
        refresh()
    }

    deinit {
        refreshTimer?.invalidate()
    }

    var menuBarSymbolName: String {
        snapshot.isRunning ? "server.rack" : "shippingbox"
    }

    var menuBarHelp: String {
        snapshot.isRunning ? "Minecraft server running" : "Minecraft server idle"
    }

    var primaryActionTitle: String {
        if snapshot.launchAgentLabel != nil { return "Restart Service" }
        if snapshot.startScriptName != nil { return "Run Start Script" }
        return "Refresh"
    }

    var canRunPrimaryAction: Bool {
        snapshot.launchAgentLabel != nil || snapshot.startScriptName != nil
    }

    var activeAgent: StudioAgentProfile? {
        agents.first(where: \.isActive) ?? agents.first
    }

    var memoryFileURL: URL {
        persistence.memoryURL
    }

    var stateDirectoryURL: URL {
        persistence.baseDirectory
    }

    var serverLabRootURL: URL {
        provisioner.baseDirectory
    }

    var suggestedStylePresets: [String] {
        ["futuristic", "medieval", "desert", "japanese", "industrial", "organic", "cottage", "cyberpunk"]
    }

    var worldInsights: [WorldInsight] {
        snapshot.worlds.map { world in
            let relatedEntries = memoryEntries.filter { $0.world == world.name }
            return WorldInsight(
                id: world.id,
                name: world.name,
                regionCount: world.regionCount,
                playerDataCount: world.playerDataCount,
                memoryEventCount: relatedEntries.count,
                lastModified: world.lastModified,
                lastEventSummary: relatedEntries.first?.summary,
                isPrimaryWorld: world.name == "world"
            )
        }
    }

    var deploymentReadinessLines: [String] {
        guard snapshot.hasServer else {
            return ["Choose or create a server to generate a deployment brief."]
        }

        var lines: [String] = []
        if snapshot.isRunning, let port = snapshot.serverPort {
            lines.append("Server is live on port \(port).")
        } else if let port = snapshot.serverPort {
            lines.append("Server is currently idle on port \(port).")
        }

        if let startScriptName = snapshot.startScriptName {
            lines.append("Start script ready: \(startScriptName).")
        } else {
            lines.append("No start script detected yet.")
        }

        lines.append(snapshot.eulaAccepted ? "EULA already accepted." : "EULA still needs review in eula.txt.")
        lines.append(snapshot.hasWorldEdit ? "WorldEdit is installed for power building." : "WorldEdit is not installed yet.")
        lines.append(snapshot.hasAIBuilder ? "AI builder tooling is available." : "AI builder tooling is not detected.")
        lines.append("\(snapshot.pluginCountLabel.capitalized) and \(snapshot.worldCountLabel).")
        return lines
    }

    var operatorCommands: [StudioCommandAction] {
        [
            StudioCommandAction(
                id: "we-wand",
                title: "Select Region",
                command: "//wand",
                note: "Grab the WorldEdit wand, then left-click and right-click your corners.",
                category: "WorldEdit"
            ),
            StudioCommandAction(
                id: "we-stack",
                title: "Stack Up",
                command: "//stack 5 up",
                note: "Repeat a finished slice vertically for fast towers and walls.",
                category: "WorldEdit"
            ),
            StudioCommandAction(
                id: "ai-plan",
                title: "AI Preview",
                command: "/aiplan small futuristic spawn hub with a center monument",
                note: "Preview a prompt before you commit to the build.",
                category: "AI Builder"
            ),
            StudioCommandAction(
                id: "ai-style",
                title: "Style Switch",
                command: "/aistyle mix japanese temple",
                note: "Blend presets quickly before planning.",
                category: "AI Builder"
            ),
            StudioCommandAction(
                id: "claim-ignore",
                title: "Ignore Claims",
                command: "/ignoreclaims",
                note: "Temporarily bypass claim protections while building as op.",
                category: "Admin"
            ),
            StudioCommandAction(
                id: "core-inspect",
                title: "CoreProtect Lookup",
                command: "/co i",
                note: "Inspect who touched a block when world memory points to a location.",
                category: "Admin"
            )
        ]
    }

    func refresh() {
        guard !isRefreshing else { return }
        isRefreshing = true
        actionMessage = ""
        clipboardMessage = ""
        let preferredPath = selectedServerPath
        let shouldCaptureMemory = autoMemoryEnabled

        Task.detached(priority: .userInitiated) {
            let discovery = ServerDiscovery()
            let memoryService = WorldMemoryService()
            let choices = discovery.discoverCandidateServers(preferredPath: preferredPath).map(\.path)
            let selectedPath = Self.resolveSelectedPath(from: choices, preferredPath: preferredPath)
            let snapshot = selectedPath.map { discovery.loadSnapshot(for: URL(fileURLWithPath: $0)) } ?? .empty
            let fetchedMemory = shouldCaptureMemory && selectedPath != nil
                ? memoryService.fetchRecentEntries(for: URL(fileURLWithPath: selectedPath!), latestLogLines: snapshot.latestLogLines)
                : []

            await MainActor.run {
                self.serverChoices = choices
                self.selectedServerPath = selectedPath ?? ""
                self.defaults.set(self.selectedServerPath, forKey: DefaultsKey.selectedServerPath)
                self.snapshot = snapshot
                self.headline = snapshot.isRunning ? "Command center live" : "Command center ready"
                self.subheadline = self.composeSubheadline(for: snapshot)
                if shouldCaptureMemory {
                    self.mergeMemoryEntries(fetchedMemory)
                }
                self.isRefreshing = false
                self.persistState()
            }
        }
    }

    func chooseServer(_ path: String) {
        selectedServerPath = path
        defaults.set(path, forKey: DefaultsKey.selectedServerPath)
        recordAppEvent(summary: "Switched selected server", detail: path)
        refresh()
    }

    func browseForServer() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.title = "Choose A Minecraft Server Folder"
        panel.message = "Pick the Paper server folder you want Minecraft Server Studio to manage."

        guard panel.runModal() == .OK, let url = panel.url else { return }
        chooseServer(url.path)
    }

    func runPrimaryAction() {
        guard snapshot.hasServer else {
            refresh()
            return
        }

        if let label = snapshot.launchAgentLabel {
            let uid = getuid()
            let result = Shell.runShell("launchctl kickstart -k gui/\(uid)/\(label.shellEscaped)")
            actionMessage = result.status == 0 ? "Restarted \(label)." : failingMessage(from: result)
            recordAppEvent(summary: actionMessage, detail: snapshot.serverDirectoryPath)
            refresh()
            return
        }

        guard let serverPath = snapshot.serverDirectoryPath, let scriptName = snapshot.startScriptName else {
            refresh()
            return
        }

        let command = "cd \(serverPath.shellEscaped) && ./\(scriptName)"
        let result = Shell.runDetachedShell(command)
        actionMessage = result.status == 0 ? "Started \(scriptName)." : failingMessage(from: result)
        recordAppEvent(summary: actionMessage, detail: serverPath)
        refresh()
    }

    func openServerFolder() {
        guard let path = snapshot.serverDirectoryPath else { return }
        NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath: path)])
    }

    func openPluginsFolder() {
        guard let path = snapshot.serverDirectoryPath else { return }
        let url = URL(fileURLWithPath: path).appendingPathComponent("plugins")
        guard FileManager.default.fileExists(atPath: url.path) else { return }
        NSWorkspace.shared.open(url)
    }

    func openWorldFolder() {
        guard let world = snapshot.worlds.first else { return }
        NSWorkspace.shared.open(URL(fileURLWithPath: world.path))
    }

    func openWorld(_ world: WorldSnapshot) {
        NSWorkspace.shared.open(URL(fileURLWithPath: world.path))
    }

    func openLatestLog() {
        guard let path = snapshot.serverDirectoryPath else { return }
        let url = URL(fileURLWithPath: path).appendingPathComponent("logs/latest.log")
        guard FileManager.default.fileExists(atPath: url.path) else { return }
        NSWorkspace.shared.open(url)
    }

    func revealServerLabRoot() {
        try? FileManager.default.createDirectory(at: serverLabRootURL, withIntermediateDirectories: true)
        NSWorkspace.shared.activateFileViewerSelecting([serverLabRootURL])
    }

    func createLocalServer() {
        guard let sourcePath = snapshot.serverDirectoryPath else {
            provisioningMessage = "Choose an existing Paper server first so Studio can clone its jar."
            return
        }

        let name = newServerName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else {
            provisioningMessage = "Give the new server a name first."
            return
        }

        let port = Int(newServerPort) ?? 25565
        let memory = max(Int(newServerMemoryMB) ?? 4096, 1024)
        let request = ServerProvisionRequest(
            sourceServerURL: URL(fileURLWithPath: sourcePath),
            name: name,
            port: port,
            memoryMB: memory,
            cloneMode: newServerCloneMode
        )

        switch provisioner.createServer(using: request) {
        case .success(let destinationURL):
            provisioningMessage = "Created \(destinationURL.lastPathComponent) in Studio’s local server lab."
            selectedPanel = .serverLab
            recordAppEvent(summary: "Created local server \(destinationURL.lastPathComponent)", detail: destinationURL.path)
            chooseServer(destinationURL.path)
        case .failure(let error):
            provisioningMessage = error.localizedDescription
        }
    }

    func copyCommand(_ command: String) {
        copyToPasteboard(command)
        clipboardMessage = "Copied \(command)"
    }

    func copyDeploymentBrief() {
        guard snapshot.hasServer else { return }

        let worldSummary = snapshot.worlds.map {
            "\($0.name): \($0.regionCount) regions, \($0.playerDataCount) players"
        }.joined(separator: "\n")
        let pluginSummary = snapshot.pluginNames.joined(separator: ", ")
        let brief = """
        Minecraft Server Studio Brief
        Server: \(snapshot.displayName)
        Path: \(snapshot.serverDirectoryPath ?? "unknown")
        Port: \(snapshot.serverPort ?? 25565)
        Running: \(snapshot.isRunning ? "yes" : "no")
        Jar: \(snapshot.jarName ?? "missing")
        Start script: \(snapshot.startScriptName ?? "missing")
        EULA accepted: \(snapshot.eulaAccepted ? "yes" : "no")
        Active agent: \(activeAgent?.name ?? "none")
        Memory events: \(memoryEntries.count)

        Worlds
        \(worldSummary.isEmpty ? "No worlds detected" : worldSummary)

        Plugins
        \(pluginSummary.isEmpty ? "No plugins detected" : pluginSummary)

        Readiness
        \(deploymentReadinessLines.joined(separator: "\n"))
        """
        copyToPasteboard(brief)
        clipboardMessage = "Copied deployment brief"
    }

    func quit() {
        NSApp.terminate(nil)
    }

    func selectAgent(_ agent: StudioAgentProfile) {
        selectedAgentID = agent.id
        selectedPanel = .agents
        loadAgentDraft(from: agent)
        persistState()
    }

    func newAgentDraft() {
        selectedAgentID = nil
        agentDraftName = ""
        agentDraftRole = ""
        agentDraftStylePreset = activeAgent?.stylePreset ?? "futuristic"
        agentDraftPromptSeed = ""
        agentDraftBehaviorNotes = ""
        agentDraftMemoryEnabled = true
    }

    func saveAgentDraft() {
        let trimmedName = agentDraftName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        let updatedAgent = StudioAgentProfile(
            id: selectedAgentID ?? UUID(),
            name: trimmedName,
            role: trimmed(agentDraftRole, fallback: "Custom Minecraft agent"),
            stylePreset: trimmed(agentDraftStylePreset, fallback: "futuristic"),
            promptSeed: trimmed(agentDraftPromptSeed, fallback: "clear builds with readable structure"),
            behaviorNotes: trimmed(agentDraftBehaviorNotes, fallback: "Acts as a customizable local Minecraft helper."),
            memoryEnabled: agentDraftMemoryEnabled,
            isActive: selectedAgentID.flatMap { id in agents.first(where: { $0.id == id })?.isActive } ?? agents.isEmpty,
            updatedAt: .now
        )

        if let index = agents.firstIndex(where: { $0.id == updatedAgent.id }) {
            agents[index] = updatedAgent
        } else {
            agents.append(updatedAgent)
        }

        if !agents.contains(where: \.isActive) {
            activateAgent(updatedAgent)
        } else {
            selectAgent(updatedAgent)
        }

        recordAppEvent(summary: "Saved agent \(updatedAgent.name)", detail: updatedAgent.stylePreset)
        persistState()
    }

    func activateAgent(_ agent: StudioAgentProfile) {
        agents = agents.map { current in
            var copy = current
            copy.isActive = current.id == agent.id
            return copy
        }
        selectedAgentID = agent.id
        if let refreshed = agents.first(where: { $0.id == agent.id }) {
            loadAgentDraft(from: refreshed)
            if jobDraftStyle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                jobDraftStyle = refreshed.stylePreset
            }
        }
        recordAppEvent(summary: "Activated agent \(agent.name)", detail: agent.stylePreset)
        persistState()
    }

    func deleteSelectedAgent() {
        guard let selectedAgentID else { return }
        guard let existing = agents.first(where: { $0.id == selectedAgentID }) else { return }
        agents.removeAll { $0.id == selectedAgentID }
        if existing.isActive, let fallback = agents.first {
            activateAgent(fallback)
        } else if let first = agents.first {
            selectAgent(first)
        } else {
            newAgentDraft()
        }
        recordAppEvent(summary: "Removed agent \(existing.name)", detail: nil)
        persistState()
    }

    func applyStylePreset(_ preset: String) {
        agentDraftStylePreset = preset
    }

    func addJob() {
        let title = jobDraftTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let prompt = jobDraftPrompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty, !prompt.isEmpty else { return }

        let style = trimmed(jobDraftStyle, fallback: activeAgent?.stylePreset ?? "futuristic")
        let job = StudioBuildJob(
            title: title,
            prompt: prompt,
            style: style,
            assignedAgentID: activeAgent?.id
        )
        jobs.insert(job, at: 0)
        jobDraftTitle = ""
        jobDraftPrompt = ""
        if jobDraftStyle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            jobDraftStyle = activeAgent?.stylePreset ?? ""
        }
        recordAppEvent(summary: "Queued build job \(job.title)", detail: style)
        persistState()
    }

    func advanceJob(_ job: StudioBuildJob) {
        guard let index = jobs.firstIndex(where: { $0.id == job.id }) else { return }
        jobs[index].status = nextStatus(after: jobs[index].status)
        jobs[index].updatedAt = .now
        recordAppEvent(summary: "Updated job \(jobs[index].title) to \(jobs[index].status.title)", detail: jobs[index].style)
        persistState()
    }

    func removeJob(_ job: StudioBuildJob) {
        jobs.removeAll { $0.id == job.id }
        recordAppEvent(summary: "Removed job \(job.title)", detail: nil)
        persistState()
    }

    func toggleAutoMemory() {
        autoMemoryEnabled.toggle()
        memoryStatusMessage = autoMemoryEnabled ? "Auto-memory on" : "Auto-memory paused"
        recordAppEvent(summary: memoryStatusMessage, detail: nil)
        persistState()
        if autoMemoryEnabled {
            refresh()
        }
    }

    func openMemoryFile() {
        guard FileManager.default.fileExists(atPath: memoryFileURL.path) else { return }
        NSWorkspace.shared.open(memoryFileURL)
    }

    func revealMemoryFolder() {
        NSWorkspace.shared.activateFileViewerSelecting([memoryFileURL])
    }

    nonisolated private static func resolveSelectedPath(from choices: [String], preferredPath: String) -> String? {
        if !preferredPath.isEmpty, choices.contains(preferredPath) {
            return preferredPath
        }
        return choices.first
    }

    private func composeSubheadline(for snapshot: ServerSnapshot) -> String {
        if snapshot.serverDirectoryPath != nil {
            let activeName = activeAgent?.name ?? "No active agent"
            let portLabel = snapshot.serverPort.map { "port \($0)" } ?? "unknown port"
            return "\(snapshot.pluginCountLabel), \(snapshot.worldCountLabel), \(portLabel), \(memoryEntries.count) memory events, agent \(activeName)"
        }
        return "Use Choose Server if your Paper folder is not in the usual places."
    }

    private func failingMessage(from result: ShellResult) -> String {
        let output = [result.stderr, result.stdout]
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .first { !$0.isEmpty } ?? "Unknown failure"
        return output
    }

    private func nextStatus(after status: StudioBuildJob.Status) -> StudioBuildJob.Status {
        switch status {
        case .queued: return .active
        case .active: return .done
        case .done: return .queued
        }
    }

    private func scheduleAutoRefresh() {
        refreshTimer?.invalidate()
        let timer = Timer.scheduledTimer(withTimeInterval: 20, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.refresh()
            }
        }
        timer.tolerance = 4
        refreshTimer = timer
    }

    private func loadState() {
        let state = persistence.loadState()
        agents = state.agents.isEmpty ? StudioAgentProfile.starterProfiles : state.agents
        jobs = state.jobs.sorted { $0.updatedAt > $1.updatedAt }
        memoryEntries = state.memoryEntries.sorted { $0.timestamp > $1.timestamp }
        autoMemoryEnabled = state.autoMemoryEnabled
        selectedPanel = state.selectedPanel ?? .commandCenter

        if let selected = state.selectedAgentID,
           let agent = agents.first(where: { $0.id == selected }) {
            loadAgentDraft(from: agent)
            selectedAgentID = selected
        } else if let active = activeAgent {
            loadAgentDraft(from: active)
            selectedAgentID = active.id
        } else {
            newAgentDraft()
        }

        if jobDraftStyle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            jobDraftStyle = activeAgent?.stylePreset ?? ""
        }
    }

    private func persistState() {
        let state = StudioPersistedState(
            agents: agents,
            jobs: jobs,
            memoryEntries: memoryEntries,
            selectedAgentID: selectedAgentID,
            autoMemoryEnabled: autoMemoryEnabled,
            selectedPanel: selectedPanel
        )
        persistence.save(state: state)
    }

    private func loadAgentDraft(from agent: StudioAgentProfile) {
        agentDraftName = agent.name
        agentDraftRole = agent.role
        agentDraftStylePreset = agent.stylePreset
        agentDraftPromptSeed = agent.promptSeed
        agentDraftBehaviorNotes = agent.behaviorNotes
        agentDraftMemoryEnabled = agent.memoryEnabled
    }

    private func recordAppEvent(summary: String, detail: String?) {
        let entry = StudioMemoryEntry(
            id: "app|\(Date().timeIntervalSince1970)|\(summary)",
            source: .app,
            timestamp: .now,
            actor: activeAgent?.name ?? "studio",
            world: snapshot.worlds.first?.name ?? "local",
            summary: summary,
            coordinates: nil,
            detail: detail
        )
        mergeMemoryEntries([entry])
        persistState()
    }

    private func mergeMemoryEntries(_ entries: [StudioMemoryEntry]) {
        guard !entries.isEmpty else { return }

        var combined = Dictionary(uniqueKeysWithValues: memoryEntries.map { ($0.id, $0) })
        for entry in entries {
            combined[entry.id] = entry
        }
        memoryEntries = combined.values.sorted { $0.timestamp > $1.timestamp }
        if memoryEntries.count > 250 {
            memoryEntries = Array(memoryEntries.prefix(250))
        }
        memoryStatusMessage = "Saved \(memoryEntries.count) world memory events."
    }

    private func copyToPasteboard(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }

    private func trimmed(_ text: String, fallback: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? fallback : trimmed
    }
}
