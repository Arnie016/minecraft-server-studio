import Foundation

struct StudioAgentProfile: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var role: String
    var stylePreset: String
    var promptSeed: String
    var behaviorNotes: String
    var memoryEnabled: Bool
    var isActive: Bool
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        role: String,
        stylePreset: String,
        promptSeed: String,
        behaviorNotes: String,
        memoryEnabled: Bool,
        isActive: Bool = false,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.role = role
        self.stylePreset = stylePreset
        self.promptSeed = promptSeed
        self.behaviorNotes = behaviorNotes
        self.memoryEnabled = memoryEnabled
        self.isActive = isActive
        self.updatedAt = updatedAt
    }

    static let starterProfiles: [StudioAgentProfile] = [
        StudioAgentProfile(
            name: "Builder One",
            role: "Large structures and district layouts",
            stylePreset: "futuristic",
            promptSeed: "bigger silhouettes, cleaner entrances, and connected substructures",
            behaviorNotes: "Favor dramatic landmarks, readable paths, and structures that make sense from a player approach.",
            memoryEnabled: true,
            isActive: true
        ),
        StudioAgentProfile(
            name: "Archivist",
            role: "World memory and change tracking",
            stylePreset: "organic",
            promptSeed: "capture meaningful world actions and summarize what changed",
            behaviorNotes: "Keep a useful diary of commands, build actions, and server incidents so the world has a persistent memory.",
            memoryEnabled: true
        ),
        StudioAgentProfile(
            name: "Navigator",
            role: "Spawn hubs, routes, and player orientation",
            stylePreset: "desert",
            promptSeed: "clear signage, portals, strong pathing, and landmark visibility",
            behaviorNotes: "Optimize for wayfinding, district identity, and first-time player onboarding.",
            memoryEnabled: false
        )
    ]
}

struct StudioBuildJob: Identifiable, Codable, Hashable {
    enum Status: String, Codable, CaseIterable {
        case queued
        case active
        case done

        var title: String {
            rawValue.capitalized
        }
    }

    var id: UUID
    var title: String
    var prompt: String
    var style: String
    var assignedAgentID: UUID?
    var status: Status
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        prompt: String,
        style: String,
        assignedAgentID: UUID?,
        status: Status = .queued,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.prompt = prompt
        self.style = style
        self.assignedAgentID = assignedAgentID
        self.status = status
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

struct StudioMemoryEntry: Identifiable, Codable, Hashable {
    enum Source: String, Codable, CaseIterable {
        case app
        case command
        case chat
        case block
        case log

        var title: String {
            switch self {
            case .app: return "App"
            case .command: return "Command"
            case .chat: return "Chat"
            case .block: return "World"
            case .log: return "Log"
            }
        }
    }

    var id: String
    var source: Source
    var timestamp: Date
    var actor: String
    var world: String?
    var summary: String
    var coordinates: String?
    var detail: String?
}

struct StudioPersistedState: Codable {
    var agents: [StudioAgentProfile]
    var jobs: [StudioBuildJob]
    var memoryEntries: [StudioMemoryEntry]
    var selectedAgentID: UUID?
    var autoMemoryEnabled: Bool

    static let empty = StudioPersistedState(
        agents: StudioAgentProfile.starterProfiles,
        jobs: [],
        memoryEntries: [],
        selectedAgentID: StudioAgentProfile.starterProfiles.first?.id,
        autoMemoryEnabled: true
    )
}
