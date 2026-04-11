import Foundation

struct WorldSnapshot: Identifiable, Sendable, Hashable {
    let id: String
    let name: String
    let path: String
    let regionCount: Int
    let playerDataCount: Int
    let lastModified: Date?

    init(
        id: String? = nil,
        name: String,
        path: String,
        regionCount: Int,
        playerDataCount: Int,
        lastModified: Date?
    ) {
        self.id = id ?? name
        self.name = name
        self.path = path
        self.regionCount = regionCount
        self.playerDataCount = playerDataCount
        self.lastModified = lastModified
    }
}

struct ServerSnapshot: Sendable {
    let serverDirectoryPath: String?
    let displayName: String
    let jarName: String?
    let startScriptName: String?
    let worlds: [WorldSnapshot]
    let pluginNames: [String]
    let latestLogLines: [String]
    let isRunning: Bool
    let serverPort: Int?
    let listenerSummary: String?
    let launchAgentLabel: String?
    let eulaAccepted: Bool
    let issues: [String]

    static let empty = ServerSnapshot(
        serverDirectoryPath: nil,
        displayName: "No server selected",
        jarName: nil,
        startScriptName: nil,
        worlds: [],
        pluginNames: [],
        latestLogLines: [],
        isRunning: false,
        serverPort: nil,
        listenerSummary: nil,
        launchAgentLabel: nil,
        eulaAccepted: false,
        issues: ["No Paper server was detected yet."]
    )

    var hasServer: Bool {
        serverDirectoryPath != nil
    }

    var pluginCountLabel: String {
        "\(pluginNames.count) plugin" + (pluginNames.count == 1 ? "" : "s")
    }

    var worldNames: [String] {
        worlds.map(\.name)
    }

    var worldCountLabel: String {
        "\(worlds.count) world" + (worlds.count == 1 ? "" : "s")
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

    var totalRegionCount: Int {
        worlds.reduce(0) { $0 + $1.regionCount }
    }

    var totalKnownPlayers: Int {
        worlds.reduce(0) { max($0, $1.playerDataCount) }
    }
}
