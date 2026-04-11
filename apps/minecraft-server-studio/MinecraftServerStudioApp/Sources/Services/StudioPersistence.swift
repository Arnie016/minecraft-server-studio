import Foundation

struct StudioPersistence {
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init() {
        encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601

        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
    }

    var baseDirectory: URL {
        let applicationSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        return applicationSupport.appendingPathComponent("MinecraftServerStudio", isDirectory: true)
    }

    var stateURL: URL {
        baseDirectory.appendingPathComponent("studio-state.json")
    }

    var memoryURL: URL {
        baseDirectory.appendingPathComponent("world-memory.json")
    }

    func loadState() -> StudioPersistedState {
        guard let data = try? Data(contentsOf: stateURL),
              let state = try? decoder.decode(StudioPersistedState.self, from: data) else {
            return .empty
        }
        return state
    }

    func save(state: StudioPersistedState) {
        try? FileManager.default.createDirectory(at: baseDirectory, withIntermediateDirectories: true)

        if let stateData = try? encoder.encode(state) {
            try? stateData.write(to: stateURL, options: [.atomic])
        }

        if let memoryData = try? encoder.encode(state.memoryEntries) {
            try? memoryData.write(to: memoryURL, options: [.atomic])
        }
    }
}
