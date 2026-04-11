import SwiftUI

private enum StudioPalette {
    static let backgroundTop = Color(red: 0.08, green: 0.10, blue: 0.08)
    static let backgroundBottom = Color(red: 0.05, green: 0.06, blue: 0.05)
    static let panel = Color(red: 0.10, green: 0.12, blue: 0.10).opacity(0.98)
    static let raised = Color(red: 0.15, green: 0.17, blue: 0.13).opacity(0.98)
    static let border = Color.white.opacity(0.08)
    static let accent = Color(red: 0.46, green: 0.87, blue: 0.39)
    static let sand = Color(red: 0.90, green: 0.78, blue: 0.52)
    static let lava = Color(red: 0.98, green: 0.46, blue: 0.24)
    static let text = Color.white.opacity(0.97)
    static let muted = Color.white.opacity(0.62)
}

struct MenuBarView: View {
    @ObservedObject var model: MinecraftStudioModel

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    StudioPalette.backgroundTop,
                    StudioPalette.accent.opacity(0.12),
                    StudioPalette.backgroundBottom
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    header
                    serverCard
                    quickActions
                    inventoryCard
                    agentCard
                    queueCard
                    memoryCard
                    pluginCard
                    logCard
                    footer
                }
                .padding(16)
            }
            .frame(width: 444, height: 880)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Minecraft Server Studio")
                    .font(.system(size: 19, weight: .black, design: .rounded))
                    .foregroundStyle(StudioPalette.text)
                Spacer()
                statusChip(model.snapshot.isRunning ? "Live" : "Idle", tint: model.snapshot.isRunning ? StudioPalette.accent.opacity(0.18) : StudioPalette.lava.opacity(0.18), foreground: model.snapshot.isRunning ? StudioPalette.accent : StudioPalette.lava)
            }

            Text(model.headline)
                .font(.caption.weight(.bold))
                .foregroundStyle(model.snapshot.isRunning ? StudioPalette.accent : StudioPalette.sand)

            Text(model.subheadline)
                .font(.caption)
                .foregroundStyle(StudioPalette.muted)
        }
    }

    private var serverCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Selected Server")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(StudioPalette.muted)
                    Text(model.snapshot.displayName)
                        .font(.headline.weight(.black))
                        .foregroundStyle(StudioPalette.text)
                    if let path = model.snapshot.serverDirectoryPath {
                        Text(path)
                            .font(.caption2)
                            .foregroundStyle(StudioPalette.muted)
                            .lineLimit(2)
                    }
                }
                Spacer()
            }

            if !model.serverChoices.isEmpty {
                Picker("Server", selection: Binding(
                    get: { model.selectedServerPath },
                    set: { model.chooseServer($0) }
                )) {
                    ForEach(model.serverChoices, id: \.self) { path in
                        Text(URL(fileURLWithPath: path).lastPathComponent).tag(path)
                    }
                }
                .pickerStyle(.menu)
            }

            HStack(spacing: 10) {
                Button {
                    model.refresh()
                } label: {
                    HStack(spacing: 8) {
                        if model.isRefreshing {
                            ProgressView()
                                .controlSize(.small)
                                .tint(.white)
                        } else {
                            Image(systemName: "arrow.clockwise")
                        }
                        Text(model.isRefreshing ? "Refreshing" : "Refresh")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button(model.primaryActionTitle) {
                    model.runPrimaryAction()
                }
                .buttonStyle(.bordered)
                .disabled(!model.canRunPrimaryAction)

                Button("Choose") {
                    model.browseForServer()
                }
                .buttonStyle(.bordered)
            }

            HStack(spacing: 8) {
                statusChip(model.activeAgent?.name ?? "No active agent", tint: StudioPalette.accent.opacity(0.14), foreground: StudioPalette.accent)
                statusChip(model.autoMemoryEnabled ? "Auto-memory on" : "Auto-memory off", tint: model.autoMemoryEnabled ? StudioPalette.sand.opacity(0.18) : StudioPalette.lava.opacity(0.18), foreground: model.autoMemoryEnabled ? StudioPalette.sand : StudioPalette.lava)
            }

            if !model.actionMessage.isEmpty {
                Text(model.actionMessage)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(StudioPalette.sand)
                    .lineLimit(2)
            }
        }
        .padding(14)
        .background(cardBackground)
    }

    private var quickActions: some View {
        HStack(spacing: 10) {
            quickAction("Reveal Server", systemName: "folder.fill") { model.openServerFolder() }
            quickAction("Plugins", systemName: "shippingbox.fill") { model.openPluginsFolder() }
            quickAction("World", systemName: "globe.europe.africa.fill") { model.openWorldFolder() }
            quickAction("Latest Log", systemName: "doc.text.fill") { model.openLatestLog() }
        }
    }

    private var inventoryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Server Inventory")
                .font(.caption.weight(.bold))
                .foregroundStyle(StudioPalette.muted)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                statTile("Jar", value: model.snapshot.jarName ?? "Missing")
                statTile("Start Script", value: model.snapshot.startScriptName ?? "Missing")
                statTile("Worlds", value: model.snapshot.worldNames.isEmpty ? "None" : model.snapshot.worldCountLabel)
                statTile("Plugins", value: model.snapshot.pluginCountLabel)
            }

            HStack(spacing: 8) {
                statusChip(model.snapshot.hasAIBuilder ? "AI builder" : "No AI builder", tint: StudioPalette.accent.opacity(0.14), foreground: model.snapshot.hasAIBuilder ? StudioPalette.accent : StudioPalette.sand)
                statusChip(model.snapshot.hasWorldEdit ? "WorldEdit" : "No WorldEdit", tint: .white.opacity(0.07), foreground: model.snapshot.hasWorldEdit ? StudioPalette.text : StudioPalette.muted)
                statusChip(model.snapshot.hasAuraSkills ? "AuraSkills" : "No AuraSkills", tint: .white.opacity(0.07), foreground: model.snapshot.hasAuraSkills ? StudioPalette.text : StudioPalette.muted)
                statusChip(model.snapshot.hasCoreProtect ? "CoreProtect" : "No CoreProtect", tint: .white.opacity(0.07), foreground: model.snapshot.hasCoreProtect ? StudioPalette.text : StudioPalette.muted)
            }

            if let listener = model.snapshot.listenerSummary {
                Text(listener)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(StudioPalette.sand)
            }

            if !model.snapshot.issues.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(model.snapshot.issues, id: \.self) { issue in
                        Text("• \(issue)")
                            .font(.caption2)
                            .foregroundStyle(StudioPalette.lava)
                    }
                }
            }
        }
        .padding(14)
        .background(cardBackground)
    }

    private var agentCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Custom Agents")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(StudioPalette.muted)
                Spacer()
                Text("\(model.agents.count) saved")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(StudioPalette.sand)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(model.agents) { agent in
                        Button {
                            model.selectAgent(agent)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(agent.name)
                                    .font(.caption.weight(.bold))
                                Text(agent.stylePreset)
                                    .font(.caption2)
                                    .foregroundStyle(StudioPalette.muted)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(agent.isActive ? StudioPalette.accent.opacity(0.18) : StudioPalette.raised)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            HStack(spacing: 10) {
                labeledTextField("Name", text: $model.agentDraftName, placeholder: "Architect")
                labeledTextField("Role", text: $model.agentDraftRole, placeholder: "Spawn builder")
            }

            labeledTextField("Style", text: $model.agentDraftStylePreset, placeholder: "futuristic")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(model.suggestedStylePresets, id: \.self) { preset in
                        Button(preset) {
                            model.applyStylePreset(preset)
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }

            labeledTextField("Prompt Seed", text: $model.agentDraftPromptSeed, placeholder: "larger scale, dramatic entrances")

            VStack(alignment: .leading, spacing: 6) {
                Text("Behavior Notes")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(StudioPalette.muted)

                TextEditor(text: $model.agentDraftBehaviorNotes)
                    .scrollContentBackground(.hidden)
                    .font(.system(size: 12.5, weight: .medium))
                    .foregroundStyle(StudioPalette.text)
                    .frame(height: 72)
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(StudioPalette.raised)
                    )
            }

            Toggle(isOn: $model.agentDraftMemoryEnabled) {
                Text("Allow this agent to participate in world memory")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(StudioPalette.secondaryText)
            }
            .toggleStyle(.switch)

            HStack(spacing: 10) {
                Button("New") {
                    model.newAgentDraft()
                }
                .buttonStyle(.bordered)

                Button("Save Agent") {
                    model.saveAgentDraft()
                }
                .buttonStyle(.borderedProminent)

                if let selected = model.selectedAgentID,
                   let agent = model.agents.first(where: { $0.id == selected }) {
                    Button("Make Active") {
                        model.activateAgent(agent)
                    }
                    .buttonStyle(.bordered)
                }

                Button("Delete") {
                    model.deleteSelectedAgent()
                }
                .buttonStyle(.bordered)
                .disabled(model.selectedAgentID == nil)
            }
        }
        .padding(14)
        .background(cardBackground)
    }

    private var queueCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Build Queue")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(StudioPalette.muted)
                Spacer()
                Text("\(model.jobs.count) jobs")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(StudioPalette.sand)
            }

            HStack(spacing: 10) {
                labeledTextField("Title", text: $model.jobDraftTitle, placeholder: "Spawn plaza")
                labeledTextField("Style", text: $model.jobDraftStyle, placeholder: model.activeAgent?.stylePreset ?? "futuristic")
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Prompt")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(StudioPalette.muted)

                TextEditor(text: $model.jobDraftPrompt)
                    .scrollContentBackground(.hidden)
                    .font(.system(size: 12.5, weight: .medium))
                    .foregroundStyle(StudioPalette.text)
                    .frame(height: 72)
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(StudioPalette.raised)
                    )
            }

            HStack {
                Text("Assigned agent: \(model.activeAgent?.name ?? "none")")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(StudioPalette.muted)
                Spacer()
                Button("Add Job") {
                    model.addJob()
                }
                .buttonStyle(.borderedProminent)
            }

            if model.jobs.isEmpty {
                Text("No queued build jobs yet.")
                    .font(.caption)
                    .foregroundStyle(StudioPalette.muted)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(model.jobs.prefix(5)) { job in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(job.title)
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(StudioPalette.text)
                                Spacer()
                                statusChip(job.status.title, tint: statusTint(for: job.status), foreground: statusForeground(for: job.status))
                            }

                            Text(job.prompt)
                                .font(.caption2)
                                .foregroundStyle(StudioPalette.muted)
                                .lineLimit(2)

                            HStack {
                                Text("Style: \(job.style)")
                                    .font(.caption2.weight(.semibold))
                                    .foregroundStyle(StudioPalette.sand)
                                Spacer()
                                Button("Advance") {
                                    model.advanceJob(job)
                                }
                                .buttonStyle(.bordered)
                                Button("Remove") {
                                    model.removeJob(job)
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(StudioPalette.raised)
                        )
                    }
                }
            }
        }
        .padding(14)
        .background(cardBackground)
    }

    private var memoryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("World Memory")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(StudioPalette.muted)
                Spacer()
                Text("\(model.memoryEntries.count) saved")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(StudioPalette.sand)
            }

            HStack(spacing: 10) {
                Button(model.autoMemoryEnabled ? "Pause Memory" : "Resume Memory") {
                    model.toggleAutoMemory()
                }
                .buttonStyle(.bordered)

                Button("Open JSON") {
                    model.openMemoryFile()
                }
                .buttonStyle(.bordered)

                Button("Reveal Folder") {
                    model.revealMemoryFolder()
                }
                .buttonStyle(.bordered)
            }

            if !model.memoryStatusMessage.isEmpty {
                Text(model.memoryStatusMessage)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(StudioPalette.sand)
            }

            if model.memoryEntries.isEmpty {
                Text("No world memory captured yet. Refresh with CoreProtect enabled or use the server to create activity.")
                    .font(.caption)
                    .foregroundStyle(StudioPalette.muted)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(model.memoryEntries.prefix(8)) { entry in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                statusChip(entry.source.title, tint: sourceTint(for: entry.source), foreground: sourceForeground(for: entry.source))
                                Text(entry.actor)
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(StudioPalette.text)
                                Spacer()
                                Text(memoryTimestamp(entry.timestamp))
                                    .font(.caption2)
                                    .foregroundStyle(StudioPalette.muted)
                            }

                            Text(entry.summary)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(StudioPalette.text)
                                .lineLimit(2)

                            HStack {
                                if let world = entry.world {
                                    Text(world)
                                        .font(.caption2)
                                        .foregroundStyle(StudioPalette.muted)
                                }
                                if let coordinates = entry.coordinates {
                                    Text(coordinates)
                                        .font(.caption2)
                                        .foregroundStyle(StudioPalette.sand)
                                }
                            }
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(StudioPalette.raised)
                        )
                    }
                }
            }
        }
        .padding(14)
        .background(cardBackground)
    }

    private var pluginCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Plugin Stack")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(StudioPalette.muted)
                Spacer()
                Text(model.snapshot.pluginCountLabel)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(StudioPalette.sand)
            }

            if model.snapshot.pluginNames.isEmpty {
                Text("No plugin jars found yet.")
                    .font(.caption)
                    .foregroundStyle(StudioPalette.muted)
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(model.snapshot.pluginNames.prefix(10), id: \.self) { plugin in
                        HStack(spacing: 8) {
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(StudioPalette.accent.opacity(0.24))
                                .frame(width: 8, height: 8)
                            Text(plugin)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(StudioPalette.text)
                                .lineLimit(1)
                        }
                    }
                }
            }
        }
        .padding(14)
        .background(cardBackground)
    }

    private var logCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Latest Log Tail")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(StudioPalette.muted)
                Spacer()
                Text("12 lines")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(StudioPalette.sand)
            }

            if model.snapshot.latestLogLines.isEmpty {
                Text("No latest.log lines were found.")
                    .font(.caption)
                    .foregroundStyle(StudioPalette.muted)
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(model.snapshot.latestLogLines, id: \.self) { line in
                        Text(line)
                            .font(.system(size: 11.5, weight: .medium, design: .monospaced))
                            .foregroundStyle(StudioPalette.text)
                            .lineLimit(1)
                    }
                }
            }
        }
        .padding(14)
        .background(cardBackground)
    }

    private var footer: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Custom agents, queue planning, and world memory now live inside the icon bar alongside server ops.")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(StudioPalette.muted)

            Button("Quit") {
                model.quit()
            }
            .buttonStyle(.plain)
            .foregroundStyle(StudioPalette.sand)
        }
        .padding(.horizontal, 2)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(StudioPalette.panel)
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(StudioPalette.border, lineWidth: 1)
            )
    }

    private func quickAction(_ title: String, systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: systemName)
                    .font(.system(size: 16, weight: .bold))
                Text(title)
                    .font(.caption2.weight(.bold))
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, minHeight: 64)
            .padding(.vertical, 4)
        }
        .buttonStyle(.bordered)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(StudioPalette.raised)
        )
    }

    private func labeledTextField(_ label: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption2.weight(.bold))
                .foregroundStyle(StudioPalette.muted)
            TextField(placeholder, text: text)
                .textFieldStyle(.plain)
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(StudioPalette.raised)
                )
        }
    }

    private func statTile(_ title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption2.weight(.bold))
                .foregroundStyle(StudioPalette.muted)
            Text(value)
                .font(.caption.weight(.bold))
                .foregroundStyle(StudioPalette.text)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(StudioPalette.raised)
        )
    }

    private func statusChip(_ title: String, tint: Color, foreground: Color) -> some View {
        Text(title)
            .font(.caption2.weight(.bold))
            .foregroundStyle(foreground)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule(style: .continuous)
                    .fill(tint)
            )
    }

    private func memoryTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    private func sourceTint(for source: StudioMemoryEntry.Source) -> Color {
        switch source {
        case .app: return StudioPalette.accent.opacity(0.18)
        case .command: return StudioPalette.sand.opacity(0.18)
        case .chat: return .blue.opacity(0.18)
        case .block: return .white.opacity(0.10)
        case .log: return StudioPalette.lava.opacity(0.18)
        }
    }

    private func sourceForeground(for source: StudioMemoryEntry.Source) -> Color {
        switch source {
        case .app: return StudioPalette.accent
        case .command: return StudioPalette.sand
        case .chat: return .blue
        case .block: return StudioPalette.text
        case .log: return StudioPalette.lava
        }
    }

    private func statusTint(for status: StudioBuildJob.Status) -> Color {
        switch status {
        case .queued: return StudioPalette.sand.opacity(0.18)
        case .active: return StudioPalette.accent.opacity(0.18)
        case .done: return .white.opacity(0.10)
        }
    }

    private func statusForeground(for status: StudioBuildJob.Status) -> Color {
        switch status {
        case .queued: return StudioPalette.sand
        case .active: return StudioPalette.accent
        case .done: return StudioPalette.text
        }
    }
}

private extension StudioPalette {
    static let secondaryText = Color(red: 0.76, green: 0.80, blue: 0.86)
}
