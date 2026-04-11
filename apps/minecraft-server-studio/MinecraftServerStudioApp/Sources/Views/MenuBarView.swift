import SwiftUI

private enum StudioPalette {
    static let backgroundTop = Color(red: 0.05, green: 0.08, blue: 0.10)
    static let backgroundMiddle = Color(red: 0.08, green: 0.18, blue: 0.16)
    static let backgroundBottom = Color(red: 0.03, green: 0.05, blue: 0.07)
    static let panel = Color(red: 0.08, green: 0.12, blue: 0.13).opacity(0.96)
    static let raised = Color(red: 0.13, green: 0.18, blue: 0.18).opacity(0.98)
    static let border = Color.white.opacity(0.10)
    static let accent = Color(red: 0.42, green: 0.92, blue: 0.78)
    static let mint = Color(red: 0.55, green: 0.94, blue: 0.82)
    static let sand = Color(red: 0.95, green: 0.82, blue: 0.58)
    static let lava = Color(red: 1.00, green: 0.46, blue: 0.32)
    static let ocean = Color(red: 0.39, green: 0.67, blue: 0.95)
    static let text = Color.white.opacity(0.98)
    static let muted = Color.white.opacity(0.64)
    static let secondaryText = Color(red: 0.78, green: 0.84, blue: 0.88)
}

struct MenuBarView: View {
    @ObservedObject var model: MinecraftStudioModel

    var body: some View {
        ZStack {
            background

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    header
                    panelSwitcher
                    panelContent
                }
                .padding(16)
            }
            .frame(width: 474, height: 920)
        }
    }

    private var background: some View {
        LinearGradient(
            colors: [
                StudioPalette.backgroundTop,
                StudioPalette.backgroundMiddle,
                StudioPalette.backgroundBottom
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(alignment: .topTrailing) {
            Circle()
                .fill(StudioPalette.accent.opacity(0.16))
                .frame(width: 220, height: 220)
                .blur(radius: 50)
                .offset(x: 70, y: -60)
        }
        .overlay(alignment: .bottomLeading) {
            Circle()
                .fill(StudioPalette.ocean.opacity(0.14))
                .frame(width: 240, height: 240)
                .blur(radius: 60)
                .offset(x: -80, y: 80)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Minecraft Server Studio")
                        .font(.system(size: 21, weight: .black, design: .rounded))
                        .foregroundStyle(StudioPalette.text)
                    Text(model.headline)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(model.snapshot.isRunning ? StudioPalette.accent : StudioPalette.sand)
                }
                Spacer()
                statusChip(
                    model.snapshot.isRunning ? "Live" : "Idle",
                    tint: model.snapshot.isRunning ? StudioPalette.accent.opacity(0.18) : StudioPalette.lava.opacity(0.18),
                    foreground: model.snapshot.isRunning ? StudioPalette.accent : StudioPalette.lava
                )
            }

            Text(model.subheadline)
                .font(.caption)
                .foregroundStyle(StudioPalette.muted)

            HStack(spacing: 8) {
                statusChip(model.activeAgent?.name ?? "No active agent", tint: StudioPalette.mint.opacity(0.14), foreground: StudioPalette.mint)
                statusChip(model.autoMemoryEnabled ? "Auto-memory on" : "Auto-memory off", tint: model.autoMemoryEnabled ? StudioPalette.sand.opacity(0.18) : StudioPalette.lava.opacity(0.18), foreground: model.autoMemoryEnabled ? StudioPalette.sand : StudioPalette.lava)
                if let port = model.snapshot.serverPort {
                    statusChip("Port \(port)", tint: StudioPalette.ocean.opacity(0.18), foreground: StudioPalette.ocean)
                }
            }
        }
        .padding(18)
        .modifier(StudioSurfaceModifier(tint: StudioPalette.accent, cornerRadius: 28))
    }

    private var panelSwitcher: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(StudioPanel.allCases) { panel in
                    Button {
                        model.selectedPanel = panel
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: panel.symbolName)
                                .font(.system(size: 12, weight: .bold))
                            Text(panel.title)
                                .font(.caption.weight(.bold))
                        }
                        .foregroundStyle(model.selectedPanel == panel ? StudioPalette.text : StudioPalette.secondaryText)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .frame(minHeight: 38)
                        .background(
                            Capsule(style: .continuous)
                                .fill(model.selectedPanel == panel ? StudioPalette.accent.opacity(0.24) : StudioPalette.raised.opacity(0.9))
                        )
                        .overlay(
                            Capsule(style: .continuous)
                                .stroke(Color.white.opacity(model.selectedPanel == panel ? 0.16 : 0.08), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 2)
        }
    }

    @ViewBuilder
    private var panelContent: some View {
        switch model.selectedPanel {
        case .commandCenter:
            VStack(alignment: .leading, spacing: 16) {
                commandCenterCard
                quickActionsCard
                readinessCard
            }
        case .worldIntel:
            VStack(alignment: .leading, spacing: 16) {
                worldIntelCard
                memoryCard
                logCard
            }
        case .serverLab:
            VStack(alignment: .leading, spacing: 16) {
                serverLabCard
                inventoryCard
                pluginCard
            }
        case .agents:
            VStack(alignment: .leading, spacing: 16) {
                agentCard
                queueCard
            }
        case .opsDeck:
            VStack(alignment: .leading, spacing: 16) {
                operatorDeckCard
                inventoryCard
                pluginCard
                logCard
            }
        }
    }

    private var commandCenterCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                titleBlock("Command Center", detail: "Your local server cockpit for status, actions, and launch readiness.")
                Spacer()
                VStack(alignment: .trailing, spacing: 6) {
                    Text(model.snapshot.displayName)
                        .font(.headline.weight(.black))
                        .foregroundStyle(StudioPalette.text)
                    Text(model.snapshot.serverDirectoryPath ?? "No server selected")
                        .font(.caption2)
                        .foregroundStyle(StudioPalette.muted)
                        .multilineTextAlignment(.trailing)
                }
            }

            HStack(spacing: 12) {
                signalTile("Worlds", value: model.snapshot.worldCountLabel, tint: StudioPalette.accent)
                signalTile("Plugins", value: model.snapshot.pluginCountLabel, tint: StudioPalette.ocean)
                signalTile("Regions", value: "\(model.snapshot.totalRegionCount)", tint: StudioPalette.sand)
                signalTile("Memory", value: "\(model.memoryEntries.count)", tint: StudioPalette.mint)
            }

            HStack(spacing: 10) {
                prominentButton(model.isRefreshing ? "Refreshing" : "Refresh", systemName: "arrow.clockwise") {
                    model.refresh()
                }
                neutralButton(model.primaryActionTitle, systemName: "play.fill") {
                    model.runPrimaryAction()
                }
                .disabled(!model.canRunPrimaryAction)
                neutralButton("Choose Server", systemName: "folder.badge.gearshape") {
                    model.browseForServer()
                }
            }

            if !model.actionMessage.isEmpty {
                Text(model.actionMessage)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(StudioPalette.sand)
            }
        }
        .padding(18)
        .modifier(StudioSurfaceModifier(tint: StudioPalette.accent, cornerRadius: 28))
    }

    private var quickActionsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            titleBlock("Quick Control", detail: "Jump straight into the live server, plugins, world folder, or logs.")

            HStack(spacing: 10) {
                quickAction("Reveal Server", systemName: "folder.fill") { model.openServerFolder() }
                quickAction("Plugins", systemName: "shippingbox.fill") { model.openPluginsFolder() }
                quickAction("World", systemName: "globe.americas.fill") { model.openWorldFolder() }
                quickAction("Latest Log", systemName: "doc.text.fill") { model.openLatestLog() }
            }
        }
        .padding(18)
        .modifier(StudioSurfaceModifier(tint: StudioPalette.ocean, cornerRadius: 28))
    }

    private var readinessCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                titleBlock("Deploy Readiness", detail: "Everything gathered so you can share, migrate, or ship the server more confidently.")
                Spacer()
                neutralButton("Copy Brief", systemName: "doc.on.doc") {
                    model.copyDeploymentBrief()
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                ForEach(model.deploymentReadinessLines, id: \.self) { line in
                    HStack(alignment: .top, spacing: 8) {
                        Circle()
                            .fill(StudioPalette.accent.opacity(0.9))
                            .frame(width: 8, height: 8)
                            .padding(.top, 4)
                        Text(line)
                            .font(.caption.weight(.medium))
                            .foregroundStyle(StudioPalette.secondaryText)
                    }
                }
            }

            if !model.clipboardMessage.isEmpty {
                Text(model.clipboardMessage)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(StudioPalette.mint)
            }
        }
        .padding(18)
        .modifier(StudioSurfaceModifier(tint: StudioPalette.mint, cornerRadius: 28))
    }

    private var worldIntelCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            titleBlock("World Intel", detail: "Understand each world’s size, player traces, and memory footprint.")

            if model.snapshot.worlds.isEmpty {
                Text("No world folders with `level.dat` were detected yet.")
                    .font(.caption)
                    .foregroundStyle(StudioPalette.muted)
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(model.snapshot.worlds) { world in
                        let insight = model.worldInsights.first(where: { $0.id == world.id })

                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(world.name)
                                    .font(.headline.weight(.black))
                                    .foregroundStyle(StudioPalette.text)
                                if insight?.isPrimaryWorld == true {
                                    statusChip("Primary", tint: StudioPalette.accent.opacity(0.18), foreground: StudioPalette.accent)
                                }
                                Spacer()
                                Button("Open") {
                                    model.openWorld(world)
                                }
                                .buttonStyle(.bordered)
                            }

                            HStack(spacing: 10) {
                                compactMetric("Regions", value: "\(world.regionCount)")
                                compactMetric("Players", value: "\(world.playerDataCount)")
                                compactMetric("Memory", value: "\(insight?.memoryEventCount ?? 0)")
                            }

                            if let lastEventSummary = insight?.lastEventSummary {
                                Text(lastEventSummary)
                                    .font(.caption)
                                    .foregroundStyle(StudioPalette.secondaryText)
                                    .lineLimit(2)
                            } else {
                                Text("No recent world-memory event recorded yet for this world.")
                                    .font(.caption)
                                    .foregroundStyle(StudioPalette.muted)
                            }
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .fill(StudioPalette.raised.opacity(0.94))
                        )
                    }
                }
            }
        }
        .padding(18)
        .modifier(StudioSurfaceModifier(tint: StudioPalette.ocean, cornerRadius: 28))
    }

    private var serverLabCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                titleBlock("Server Lab", detail: "Spin up new local servers, clone your creative stack, and keep a dedicated studio workspace.")
                Spacer()
                neutralButton("Reveal Lab", systemName: "folder") {
                    model.revealServerLabRoot()
                }
            }

            HStack(spacing: 10) {
                labeledTextField("Server Name", text: $model.newServerName, placeholder: "creative-sandbox")
                labeledTextField("Port", text: $model.newServerPort, placeholder: "25565")
            }

            HStack(spacing: 10) {
                labeledTextField("Memory MB", text: $model.newServerMemoryMB, placeholder: "4096")
                VStack(alignment: .leading, spacing: 6) {
                    Text("Clone Mode")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(StudioPalette.muted)
                    Picker("Clone Mode", selection: $model.newServerCloneMode) {
                        ForEach(StudioPluginCloneMode.allCases, id: \.self) { mode in
                            Text(mode.title).tag(mode)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(StudioPalette.raised)
                    )
                }
            }

            Text(model.newServerCloneMode.summary)
                .font(.caption)
                .foregroundStyle(StudioPalette.secondaryText)

            HStack(spacing: 10) {
                prominentButton("Create Local Server", systemName: "plus.circle.fill") {
                    model.createLocalServer()
                }
                neutralButton("Copy Brief", systemName: "doc.on.doc") {
                    model.copyDeploymentBrief()
                }
            }

            if !model.provisioningMessage.isEmpty {
                Text(model.provisioningMessage)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(StudioPalette.mint)
                    .lineLimit(3)
            }

            Text("Source jar: \(model.snapshot.jarName ?? "Choose a server with Paper installed first.")")
                .font(.caption2)
                .foregroundStyle(StudioPalette.muted)
        }
        .padding(18)
        .modifier(StudioSurfaceModifier(tint: StudioPalette.mint, cornerRadius: 28))
    }

    private var agentCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                titleBlock("Custom Agents", detail: "Shape agent personalities for builders, archivists, and operators.")
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
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(agent.isActive ? StudioPalette.accent.opacity(0.20) : StudioPalette.raised)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            HStack(spacing: 10) {
                labeledTextField("Name", text: $model.agentDraftName, placeholder: "Architect")
                labeledTextField("Role", text: $model.agentDraftRole, placeholder: "District builder")
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

            labeledTextField("Prompt Seed", text: $model.agentDraftPromptSeed, placeholder: "dramatic scale, clear landmarks")

            VStack(alignment: .leading, spacing: 6) {
                Text("Behavior Notes")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(StudioPalette.muted)

                TextEditor(text: $model.agentDraftBehaviorNotes)
                    .scrollContentBackground(.hidden)
                    .font(.system(size: 12.5, weight: .medium))
                    .foregroundStyle(StudioPalette.text)
                    .frame(height: 78)
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(StudioPalette.raised)
                    )
            }

            Toggle(isOn: $model.agentDraftMemoryEnabled) {
                Text("Let this agent write to world memory")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(StudioPalette.secondaryText)
            }
            .toggleStyle(.switch)

            HStack(spacing: 10) {
                neutralButton("New", systemName: "plus") { model.newAgentDraft() }
                prominentButton("Save Agent", systemName: "square.and.arrow.down.fill") { model.saveAgentDraft() }
                if let selected = model.selectedAgentID,
                   let agent = model.agents.first(where: { $0.id == selected }) {
                    neutralButton("Make Active", systemName: "star.fill") { model.activateAgent(agent) }
                }
                neutralButton("Delete", systemName: "trash") { model.deleteSelectedAgent() }
                    .disabled(model.selectedAgentID == nil)
            }
        }
        .padding(18)
        .modifier(StudioSurfaceModifier(tint: StudioPalette.accent, cornerRadius: 28))
    }

    private var queueCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                titleBlock("Build Queue", detail: "Stage bigger ambitions and assign them to the active agent.")
                Spacer()
                Text("\(model.jobs.count) jobs")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(StudioPalette.sand)
            }

            HStack(spacing: 10) {
                labeledTextField("Title", text: $model.jobDraftTitle, placeholder: "Spawn district")
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
                    .frame(height: 78)
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(StudioPalette.raised)
                    )
            }

            HStack {
                Text("Assigned agent: \(model.activeAgent?.name ?? "none")")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(StudioPalette.muted)
                Spacer()
                prominentButton("Add Job", systemName: "plus.circle.fill") { model.addJob() }
            }

            if model.jobs.isEmpty {
                Text("No queued build jobs yet.")
                    .font(.caption)
                    .foregroundStyle(StudioPalette.muted)
            } else {
                VStack(alignment: .leading, spacing: 10) {
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
                                .foregroundStyle(StudioPalette.secondaryText)
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
                                .fill(StudioPalette.raised.opacity(0.94))
                        )
                    }
                }
            }
        }
        .padding(18)
        .modifier(StudioSurfaceModifier(tint: StudioPalette.sand, cornerRadius: 28))
    }

    private var memoryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                titleBlock("World Memory", detail: "An automatic timeline built from CoreProtect activity and notable server logs.")
                Spacer()
                Text("\(model.memoryEntries.count) saved")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(StudioPalette.sand)
            }

            HStack(spacing: 10) {
                neutralButton(model.autoMemoryEnabled ? "Pause Memory" : "Resume Memory", systemName: model.autoMemoryEnabled ? "pause.fill" : "play.fill") {
                    model.toggleAutoMemory()
                }
                neutralButton("Open JSON", systemName: "doc.text") { model.openMemoryFile() }
                neutralButton("Reveal Folder", systemName: "folder") { model.revealMemoryFolder() }
            }

            if !model.memoryStatusMessage.isEmpty {
                Text(model.memoryStatusMessage)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(StudioPalette.mint)
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
                                .fill(StudioPalette.raised.opacity(0.94))
                        )
                    }
                }
            }
        }
        .padding(18)
        .modifier(StudioSurfaceModifier(tint: StudioPalette.ocean, cornerRadius: 28))
    }

    private var operatorDeckCard: some View {
        let categories = Dictionary(grouping: model.operatorCommands, by: \.category)

        return VStack(alignment: .leading, spacing: 14) {
            titleBlock("Ops Deck", detail: "Give yourself or other operators immediate power tools for world editing, AI builds, and admin recovery.")

            ForEach(categories.keys.sorted(), id: \.self) { category in
                VStack(alignment: .leading, spacing: 8) {
                    Text(category)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(StudioPalette.sand)

                    ForEach(categories[category] ?? []) { item in
                        HStack(alignment: .top, spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.title)
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(StudioPalette.text)
                                Text(item.note)
                                    .font(.caption2)
                                    .foregroundStyle(StudioPalette.secondaryText)
                                    .lineLimit(2)
                                Text(item.command)
                                    .font(.system(size: 11.5, weight: .semibold, design: .monospaced))
                                    .foregroundStyle(StudioPalette.mint)
                            }
                            Spacer()
                            Button("Copy") {
                                model.copyCommand(item.command)
                            }
                            .buttonStyle(.bordered)
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(StudioPalette.raised.opacity(0.94))
                        )
                    }
                }
            }

            if !model.clipboardMessage.isEmpty {
                Text(model.clipboardMessage)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(StudioPalette.mint)
            }
        }
        .padding(18)
        .modifier(StudioSurfaceModifier(tint: StudioPalette.sand, cornerRadius: 28))
    }

    private var inventoryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            titleBlock("Server Inventory", detail: "Everything the selected server is carrying right now.")

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                statTile("Jar", value: model.snapshot.jarName ?? "Missing")
                statTile("Start Script", value: model.snapshot.startScriptName ?? "Missing")
                statTile("Worlds", value: model.snapshot.worldCountLabel)
                statTile("Regions", value: "\(model.snapshot.totalRegionCount)")
                statTile("Players", value: "\(model.snapshot.totalKnownPlayers)")
                statTile("Plugins", value: model.snapshot.pluginCountLabel)
            }

            HStack(spacing: 8) {
                statusChip(model.snapshot.hasAIBuilder ? "AI builder" : "No AI builder", tint: StudioPalette.accent.opacity(0.18), foreground: model.snapshot.hasAIBuilder ? StudioPalette.accent : StudioPalette.sand)
                statusChip(model.snapshot.hasWorldEdit ? "WorldEdit" : "No WorldEdit", tint: Color.white.opacity(0.08), foreground: model.snapshot.hasWorldEdit ? StudioPalette.text : StudioPalette.muted)
                statusChip(model.snapshot.hasCoreProtect ? "CoreProtect" : "No CoreProtect", tint: Color.white.opacity(0.08), foreground: model.snapshot.hasCoreProtect ? StudioPalette.text : StudioPalette.muted)
                statusChip(model.snapshot.hasBlueMap ? "BlueMap" : "No BlueMap", tint: Color.white.opacity(0.08), foreground: model.snapshot.hasBlueMap ? StudioPalette.text : StudioPalette.muted)
            }

            Text(model.snapshot.listenerSummary ?? "No listener detected")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(StudioPalette.sand)

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
        .padding(18)
        .modifier(StudioSurfaceModifier(tint: StudioPalette.ocean, cornerRadius: 28))
    }

    private var pluginCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                titleBlock("Plugin Stack", detail: "See exactly what power-ups are installed on the selected server.")
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
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ForEach(model.snapshot.pluginNames.prefix(12), id: \.self) { plugin in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(StudioPalette.accent.opacity(0.9))
                                .frame(width: 8, height: 8)
                            Text(plugin)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(StudioPalette.text)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(StudioPalette.raised.opacity(0.94))
                        )
                    }
                }
            }
        }
        .padding(18)
        .modifier(StudioSurfaceModifier(tint: StudioPalette.accent, cornerRadius: 28))
    }

    private var logCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                titleBlock("Latest Log Tail", detail: "A quick pulse on joins, AI failures, and server warnings.")
                Spacer()
                Text("\(model.snapshot.latestLogLines.count) lines")
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
        .padding(18)
        .modifier(StudioSurfaceModifier(tint: StudioPalette.lava, cornerRadius: 28))
    }

    private func titleBlock(_ title: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline.weight(.black))
                .foregroundStyle(StudioPalette.text)
            Text(detail)
                .font(.caption)
                .foregroundStyle(StudioPalette.muted)
        }
    }

    private func prominentButton(_ title: String, systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemName)
                .font(.caption.weight(.bold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
        }
        .buttonStyle(.borderedProminent)
        .tint(StudioPalette.accent)
    }

    private func neutralButton(_ title: String, systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemName)
                .font(.caption.weight(.bold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
        }
        .buttonStyle(.bordered)
        .tint(.white)
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
            .frame(maxWidth: .infinity, minHeight: 70)
        }
        .buttonStyle(.plain)
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(StudioPalette.raised.opacity(0.94))
        )
    }

    private func compactMetric(_ title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption2.weight(.bold))
                .foregroundStyle(StudioPalette.muted)
            Text(value)
                .font(.caption.weight(.bold))
                .foregroundStyle(StudioPalette.text)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(StudioPalette.raised.opacity(0.94))
        )
    }

    private func signalTile(_ title: String, value: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption2.weight(.bold))
                .foregroundStyle(StudioPalette.muted)
            Text(value)
                .font(.caption.weight(.bold))
                .foregroundStyle(StudioPalette.text)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(tint.opacity(0.14))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(tint.opacity(0.28), lineWidth: 1)
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
                .foregroundStyle(StudioPalette.text)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
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
                .fill(StudioPalette.raised.opacity(0.94))
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
        case .chat: return StudioPalette.ocean.opacity(0.18)
        case .block: return Color.white.opacity(0.10)
        case .log: return StudioPalette.lava.opacity(0.18)
        }
    }

    private func sourceForeground(for source: StudioMemoryEntry.Source) -> Color {
        switch source {
        case .app: return StudioPalette.accent
        case .command: return StudioPalette.sand
        case .chat: return StudioPalette.ocean
        case .block: return StudioPalette.text
        case .log: return StudioPalette.lava
        }
    }

    private func statusTint(for status: StudioBuildJob.Status) -> Color {
        switch status {
        case .queued: return StudioPalette.sand.opacity(0.18)
        case .active: return StudioPalette.accent.opacity(0.18)
        case .done: return Color.white.opacity(0.10)
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

private struct StudioSurfaceModifier: ViewModifier {
    let tint: Color
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        if #available(macOS 26.0, *) {
            content
                .background(Color.white.opacity(0.01), in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .glassEffect(.regular.tint(tint.opacity(0.16)), in: .rect(cornerRadius: cornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
        } else {
            content
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(StudioPalette.panel)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(StudioPalette.border, lineWidth: 1)
                )
        }
    }
}
