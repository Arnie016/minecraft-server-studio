import SwiftUI

@main
struct MinecraftServerStudioApp: App {
    @StateObject private var model = MinecraftStudioModel()

    var body: some Scene {
        MenuBarExtra {
            MenuBarView(model: model)
        } label: {
            Label("Minecraft Server Studio", systemImage: model.menuBarSymbolName)
                .help(model.menuBarHelp)
        }
        .menuBarExtraStyle(.window)

        Settings {
            VStack(alignment: .leading, spacing: 12) {
                Text("Minecraft Server Studio")
                    .font(.title2.weight(.bold))
                Text("A compact menu bar surface for local Paper server visibility, plugin inventory, and Codex-oriented Minecraft workflows.")
                    .foregroundStyle(.secondary)
                if let serverPath = model.snapshot.serverDirectoryPath {
                    Text("Selected server: \(serverPath)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Text("Server lab root: \(model.serverLabRootURL.path)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Text("Memory file: \(model.memoryFileURL.path)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding(24)
            .frame(width: 440)
        }
    }
}
