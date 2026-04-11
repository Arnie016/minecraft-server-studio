import Foundation

struct WorldMemoryService {
    func fetchRecentEntries(for serverURL: URL, latestLogLines: [String], limit: Int = 60) -> [StudioMemoryEntry] {
        var entries = fetchCoreProtectEntries(for: serverURL, limit: limit)
        entries.append(contentsOf: parseLogEntries(from: latestLogLines))
        return Array(
            Dictionary(uniqueKeysWithValues: entries.map { ($0.id, $0) })
                .values
                .sorted { $0.timestamp > $1.timestamp }
                .prefix(limit)
        )
    }

    private func fetchCoreProtectEntries(for serverURL: URL, limit: Int) -> [StudioMemoryEntry] {
        let databaseURL = serverURL
            .appendingPathComponent("plugins", isDirectory: true)
            .appendingPathComponent("CoreProtect", isDirectory: true)
            .appendingPathComponent("database.db")

        guard FileManager.default.fileExists(atPath: databaseURL.path) else {
            return []
        }

        let query = """
        SELECT * FROM (
            SELECT c.time, 'command' AS source, COALESCE(u.user, 'server') AS actor, COALESCE(w.world, '') AS world, c.x, c.y, c.z, c.message AS summary
            FROM co_command c
            LEFT JOIN co_user u ON c.user = u.id
            LEFT JOIN co_world w ON c.wid = w.id
            UNION ALL
            SELECT h.time, 'chat' AS source, COALESCE(u.user, 'server') AS actor, COALESCE(w.world, '') AS world, h.x, h.y, h.z, h.message AS summary
            FROM co_chat h
            LEFT JOIN co_user u ON h.user = u.id
            LEFT JOIN co_world w ON h.wid = w.id
            UNION ALL
            SELECT b.time, 'block' AS source, COALESCE(u.user, 'server') AS actor, COALESCE(w.world, '') AS world, b.x, b.y, b.z,
                CASE b.action
                    WHEN 1 THEN 'placed ' || REPLACE(COALESCE(m.material, 'block'), 'minecraft:', '')
                    WHEN 0 THEN 'removed ' || REPLACE(COALESCE(m.material, 'block'), 'minecraft:', '')
                    ELSE 'touched ' || REPLACE(COALESCE(m.material, 'block'), 'minecraft:', '')
                END AS summary
            FROM co_block b
            LEFT JOIN co_user u ON b.user = u.id
            LEFT JOIN co_world w ON b.wid = w.id
            LEFT JOIN co_material_map m ON b.type = m.id
        )
        ORDER BY time DESC
        LIMIT \(limit);
        """

        let result = Shell.run("/usr/bin/sqlite3", arguments: ["-separator", "\t", databaseURL.path, query])
        guard result.status == 0 else { return [] }

        return result.stdout
            .split(whereSeparator: \.isNewline)
            .compactMap { parseCoreProtectRow(String($0)) }
    }

    private func parseCoreProtectRow(_ row: String) -> StudioMemoryEntry? {
        let fields = row.components(separatedBy: "\t")
        guard fields.count >= 8 else { return nil }

        let timeValue = TimeInterval(fields[0]) ?? 0
        let source = StudioMemoryEntry.Source(rawValue: fields[1]) ?? .log
        let actor = fields[2].isEmpty ? "server" : fields[2]
        let world = fields[3].isEmpty ? nil : fields[3]
        let coordinates = "\(fields[4]), \(fields[5]), \(fields[6])"
        let summary = fields[7].trimmingCharacters(in: .whitespacesAndNewlines)

        return StudioMemoryEntry(
            id: makeID(source: source.rawValue, time: fields[0], actor: actor, summary: summary, coordinates: coordinates),
            source: source,
            timestamp: Date(timeIntervalSince1970: timeValue),
            actor: actor,
            world: world,
            summary: summary,
            coordinates: coordinates,
            detail: source == .command || source == .chat ? summary : nil
        )
    }

    private func parseLogEntries(from lines: [String]) -> [StudioMemoryEntry] {
        lines.compactMap { line in
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return nil }
            let isInteresting =
                trimmed.contains("[WARN]") ||
                trimmed.contains("[ERROR]") ||
                trimmed.contains("AI plan failed") ||
                trimmed.contains("joined the game") ||
                trimmed.contains("left the game") ||
                trimmed.contains("timed out") ||
                trimmed.contains("Unable to resolve the skin api")
            guard isInteresting else { return nil }

            return StudioMemoryEntry(
                id: makeID(source: "log", time: trimmed.prefix(10).description, actor: "server", summary: trimmed, coordinates: nil),
                source: .log,
                timestamp: parseLogTimestamp(from: trimmed) ?? .now,
                actor: "server",
                world: nil,
                summary: trimmed,
                coordinates: nil,
                detail: trimmed
            )
        }
    }

    private func parseLogTimestamp(from line: String) -> Date? {
        guard line.hasPrefix("["), let endIndex = line.firstIndex(of: "]") else { return nil }
        let timeString = String(line[line.index(after: line.startIndex)..<endIndex])
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        guard let timeOnly = formatter.date(from: timeString) else { return nil }

        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month, .day], from: now)
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: timeOnly)
        return calendar.date(from: DateComponents(
            year: components.year,
            month: components.month,
            day: components.day,
            hour: timeComponents.hour,
            minute: timeComponents.minute,
            second: timeComponents.second
        ))
    }

    private func makeID(source: String, time: String, actor: String, summary: String, coordinates: String?) -> String {
        [source, time, actor, summary, coordinates ?? ""].joined(separator: "|")
    }
}
