import Foundation

struct ServerSnapshot: Sendable {
    let serverDirectoryPath: String?
    let displayName: String
    let jarName: String?
    let startScriptName: String?
    let worldNames: [String]
    let pluginNames: [String]
    let latestLogLines: [String]
    let isRunning: Bool
    let listenerSummary: String?
    let launchAgentLabel: String?
    let issues: [String]

    static let empty = ServerSnapshot(
        serverDirectoryPath: nil,
        displayName: "No server selected",
        jarName: nil,
        startScriptName: nil,
        worldNames: [],
        pluginNames: [],
        latestLogLines: [],
        isRunning: false,
        listenerSummary: nil,
        launchAgentLabel: nil,
        issues: ["No Paper server was detected yet."]
    )

    var hasServer: Bool {
        serverDirectoryPath != nil
    }

    var pluginCountLabel: String {
        "\(pluginNames.count) plugin" + (pluginNames.count == 1 ? "" : "s")
    }

    var worldCountLabel: String {
        "\(worldNames.count) world" + (worldNames.count == 1 ? "" : "s")
    }

    var hasAIBuilder: Bool {
        pluginNames.contains { name in
            let lowered = name.lowercased()
            return lowered.contains("acacia") || lowered.contains("ai")
        }
    }

    var hasWorldEdit: Bool {
        pluginNames.contains { $0.lowercased().contains("worldedit") }
    }

    var hasAuraSkills: Bool {
        pluginNames.contains { $0.lowercased().contains("auraskills") }
    }

    var hasCoreProtect: Bool {
        pluginNames.contains { $0.lowercased().contains("coreprotect") }
    }

    var hasBlueMap: Bool {
        pluginNames.contains { $0.lowercased().contains("bluemap") }
    }
}
