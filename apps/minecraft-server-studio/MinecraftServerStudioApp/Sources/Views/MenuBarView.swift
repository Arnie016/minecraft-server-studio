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
                    pluginCard
                    logCard
                    footer
                }
                .padding(16)
            }
            .frame(width: 428, height: 700)
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
            Text("Codex skills in this repo cover server ops, command coaching, and AI builder work.")
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
}
