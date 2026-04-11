import Foundation

enum StudioPanel: String, CaseIterable, Identifiable, Codable {
    case commandCenter
    case worldIntel
    case serverLab
    case agents
    case opsDeck

    var id: String { rawValue }

    var title: String {
        switch self {
        case .commandCenter: return "Command Center"
        case .worldIntel: return "World Intel"
        case .serverLab: return "Server Lab"
        case .agents: return "Agents"
        case .opsDeck: return "Ops Deck"
        }
    }

    var symbolName: String {
        switch self {
        case .commandCenter: return "sparkles.tv"
        case .worldIntel: return "globe.americas.fill"
        case .serverLab: return "shippingbox.circle.fill"
        case .agents: return "person.3.sequence.fill"
        case .opsDeck: return "slider.horizontal.3"
        }
    }
}

enum StudioPluginCloneMode: String, CaseIterable, Codable, Hashable {
    case none
    case creativeTooling
    case fullStack

    var title: String {
        switch self {
        case .none: return "Fresh"
        case .creativeTooling: return "Creative Tools"
        case .fullStack: return "Full Stack"
        }
    }

    var summary: String {
        switch self {
        case .none:
            return "Only scaffold the new Paper server files."
        case .creativeTooling:
            return "Copy creative plugins like AI builder, WorldEdit, and CoreProtect."
        case .fullStack:
            return "Copy the current plugin stack for a near-clone server."
        }
    }
}

struct WorldInsight: Identifiable, Hashable {
    let id: String
    let name: String
    let regionCount: Int
    let playerDataCount: Int
    let memoryEventCount: Int
    let lastModified: Date?
    let lastEventSummary: String?
    let isPrimaryWorld: Bool
}

struct StudioCommandAction: Identifiable, Hashable {
    let id: String
    let title: String
    let command: String
    let note: String
    let category: String
}

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
    var selectedPanel: StudioPanel?

    static let empty = StudioPersistedState(
        agents: StudioAgentProfile.starterProfiles,
        jobs: [],
        memoryEntries: [],
        selectedAgentID: StudioAgentProfile.starterProfiles.first?.id,
        autoMemoryEnabled: true,
        selectedPanel: .commandCenter
    )
}
