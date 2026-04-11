import AppKit
import Foundation

@MainActor
final class MinecraftStudioModel: ObservableObject {
    private enum DefaultsKey {
        static let selectedServerPath = "minecraftServerStudio.selectedServerPath"
    }

    @Published var serverChoices: [String] = []
    @Published var selectedServerPath: String = ""
    @Published private(set) var snapshot: ServerSnapshot = .empty
    @Published private(set) var headline: String = "Scanning for Paper servers"
    @Published private(set) var subheadline: String = "Point it at a local server and use the menu bar to inspect the stack."
    @Published private(set) var isRefreshing = false
    @Published private(set) var actionMessage: String = ""

    private let defaults = UserDefaults.standard
    private let discovery = ServerDiscovery()

    init() {
        selectedServerPath = defaults.string(forKey: DefaultsKey.selectedServerPath) ?? ""
        refresh()
    }

    var menuBarSymbolName: String {
        snapshot.isRunning ? "server.rack" : "shippingbox"
    }

    var menuBarHelp: String {
        snapshot.isRunning ? "Minecraft server running" : "Minecraft server idle"
    }

    var selectedServerDisplay: String {
        if selectedServerPath.isEmpty { return "Auto detect" }
        return URL(fileURLWithPath: selectedServerPath).lastPathComponent
    }

    var primaryActionTitle: String {
        if snapshot.launchAgentLabel != nil { return "Restart Service" }
        if snapshot.startScriptName != nil { return "Run Start Script" }
        return "Refresh"
    }

    var canRunPrimaryAction: Bool {
        snapshot.launchAgentLabel != nil || snapshot.startScriptName != nil
    }

    func refresh() {
        isRefreshing = true
        actionMessage = ""
        let preferredPath = selectedServerPath

        Task.detached(priority: .userInitiated) {
            let discovery = ServerDiscovery()
            let choices = discovery.discoverCandidateServers(preferredPath: preferredPath).map(\.path)
            let selectedPath = Self.resolveSelectedPath(from: choices, preferredPath: preferredPath)
            let snapshot = selectedPath.map { discovery.loadSnapshot(for: URL(fileURLWithPath: $0)) } ?? .empty

            await MainActor.run {
                self.serverChoices = choices
                self.selectedServerPath = selectedPath ?? ""
                self.defaults.set(self.selectedServerPath, forKey: DefaultsKey.selectedServerPath)
                self.snapshot = snapshot
                self.headline = snapshot.isRunning ? "Server live" : "Server ready"
                self.subheadline = self.composeSubheadline(for: snapshot)
                self.isRefreshing = false
            }
        }
    }

    func chooseServer(_ path: String) {
        selectedServerPath = path
        defaults.set(path, forKey: DefaultsKey.selectedServerPath)
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
        guard let path = snapshot.serverDirectoryPath else { return }
        let worldName = snapshot.worldNames.first ?? "world"
        let url = URL(fileURLWithPath: path).appendingPathComponent(worldName)
        guard FileManager.default.fileExists(atPath: url.path) else { return }
        NSWorkspace.shared.open(url)
    }

    func openLatestLog() {
        guard let path = snapshot.serverDirectoryPath else { return }
        let url = URL(fileURLWithPath: path).appendingPathComponent("logs/latest.log")
        guard FileManager.default.fileExists(atPath: url.path) else { return }
        NSWorkspace.shared.open(url)
    }

    func quit() {
        NSApp.terminate(nil)
    }

    nonisolated private static func resolveSelectedPath(from choices: [String], preferredPath: String) -> String? {
        if !preferredPath.isEmpty, choices.contains(preferredPath) {
            return preferredPath
        }
        return choices.first
    }

    private func composeSubheadline(for snapshot: ServerSnapshot) -> String {
        if let path = snapshot.serverDirectoryPath {
            return "\(snapshot.pluginCountLabel), \(snapshot.worldCountLabel), folder \(URL(fileURLWithPath: path).lastPathComponent)"
        }
        return "Use Choose Server if your Paper folder is not in the usual places."
    }

    private func failingMessage(from result: ShellResult) -> String {
        let output = [result.stderr, result.stdout]
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .first { !$0.isEmpty } ?? "Unknown failure"
        return output
    }
}
