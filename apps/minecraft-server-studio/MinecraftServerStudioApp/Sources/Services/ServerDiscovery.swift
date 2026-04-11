import Foundation

struct ServerDiscovery {
    func discoverCandidateServers(preferredPath: String?) -> [URL] {
        var candidates: [URL] = []

        if let preferredPath, !preferredPath.isEmpty {
            let preferredURL = URL(fileURLWithPath: preferredPath)
            if isCandidateServerDirectory(preferredURL) {
                candidates.append(preferredURL)
            }
        }

        for root in candidateRoots() {
            scanDirectory(root, depth: 0, maxDepth: 3, results: &candidates)
        }

        var unique: [URL] = []
        var seen = Set<String>()
        for url in candidates {
            let standardized = url.standardizedFileURL.path
            if seen.insert(standardized).inserted {
                unique.append(url)
            }
        }
        return unique.sorted { $0.path < $1.path }
    }

    func loadSnapshot(for serverURL: URL) -> ServerSnapshot {
        let fileManager = FileManager.default
        let jarName = firstMatchingFileName(in: serverURL, matches: ["paper-", "purpur-", "spigot-", "server.jar"])
        let startScriptName = ["start-paper.sh", "start-server.sh", "run.sh"].first {
            fileManager.fileExists(atPath: serverURL.appendingPathComponent($0).path)
        }

        let pluginNames = fileNames(in: serverURL.appendingPathComponent("plugins"), suffix: ".jar")
        let worldNames = subdirectoryNames(in: serverURL).filter { name in
            name == "world" || name.hasPrefix("world_")
        }
        let latestLogLines = tailLines(in: serverURL.appendingPathComponent("logs/latest.log"), limit: 12)
        let listenerOutput = Shell.runShell("lsof -nP -iTCP:25565 -sTCP:LISTEN | tail -n +2")
        let isRunning = listenerOutput.status == 0 && !listenerOutput.stdout.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let listenerSummary = isRunning ? "Port 25565 listening" : nil

        var issues: [String] = []
        if jarName == nil {
            issues.append("No Paper or server jar was found in this folder.")
        }
        if pluginNames.isEmpty {
            issues.append("No plugin jars were found in the plugins folder.")
        }

        return ServerSnapshot(
            serverDirectoryPath: serverURL.path,
            displayName: serverURL.lastPathComponent,
            jarName: jarName,
            startScriptName: startScriptName,
            worldNames: worldNames,
            pluginNames: pluginNames,
            latestLogLines: latestLogLines,
            isRunning: isRunning,
            listenerSummary: listenerSummary,
            launchAgentLabel: launchAgentLabel(for: serverURL),
            issues: issues
        )
    }

    private func candidateRoots() -> [URL] {
        let home = FileManager.default.homeDirectoryForCurrentUser
        return [
            home.appendingPathComponent("minecraftserverlocal"),
            home.appendingPathComponent("Desktop"),
            home.appendingPathComponent("Library/Mobile Documents/com~apple~CloudDocs/Desktop"),
            home.appendingPathComponent("Documents")
        ]
    }

    private func scanDirectory(_ url: URL, depth: Int, maxDepth: Int, results: inout [URL]) {
        guard depth <= maxDepth else { return }
        let fileManager = FileManager.default
        var isDirectory: ObjCBool = false
        guard fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory), isDirectory.boolValue else { return }

        if isCandidateServerDirectory(url) {
            results.append(url)
        }

        guard let children = try? fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsHiddenFiles]) else {
            return
        }

        for child in children {
            if shouldSkip(child) { continue }
            scanDirectory(child, depth: depth + 1, maxDepth: maxDepth, results: &results)
        }
    }

    private func shouldSkip(_ url: URL) -> Bool {
        let lowered = url.lastPathComponent.lowercased()
        if lowered.hasPrefix(".") { return true }
        if lowered == "node_modules" || lowered == "deriveddata" || lowered == ".git" { return true }
        return false
    }

    private func isCandidateServerDirectory(_ url: URL) -> Bool {
        let fileManager = FileManager.default
        let pluginsPath = url.appendingPathComponent("plugins").path
        let propertiesPath = url.appendingPathComponent("server.properties").path
        let eulaPath = url.appendingPathComponent("eula.txt").path
        let hasPlugins = fileManager.fileExists(atPath: pluginsPath)
        let hasProperties = fileManager.fileExists(atPath: propertiesPath)
        let hasEula = fileManager.fileExists(atPath: eulaPath)
        let hasJar = firstMatchingFileName(in: url, matches: ["paper-", "purpur-", "spigot-", "server.jar"]) != nil
        return hasPlugins && (hasJar || hasProperties || hasEula)
    }

    private func firstMatchingFileName(in directory: URL, matches patterns: [String]) -> String? {
        let fileManager = FileManager.default
        guard let files = try? fileManager.contentsOfDirectory(atPath: directory.path) else {
            return nil
        }
        return files.first { name in
            patterns.contains { pattern in
                if pattern.hasSuffix(".jar") {
                    return name == pattern
                }
                return name.hasPrefix(pattern) && name.hasSuffix(".jar")
            }
        }
    }

    private func fileNames(in directory: URL, suffix: String) -> [String] {
        let fileManager = FileManager.default
        guard let files = try? fileManager.contentsOfDirectory(atPath: directory.path) else {
            return []
        }
        return files
            .filter { $0.lowercased().hasSuffix(suffix) }
            .sorted()
    }

    private func subdirectoryNames(in directory: URL) -> [String] {
        let fileManager = FileManager.default
        guard let children = try? fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsHiddenFiles]) else {
            return []
        }
        return children.compactMap { child in
            var isDirectory: ObjCBool = false
            guard fileManager.fileExists(atPath: child.path, isDirectory: &isDirectory), isDirectory.boolValue else {
                return nil
            }
            return child.lastPathComponent
        }
        .sorted()
    }

    private func tailLines(in fileURL: URL, limit: Int) -> [String] {
        guard let data = try? Data(contentsOf: fileURL),
              let contents = String(data: data, encoding: .utf8) else {
            return []
        }
        return contents
            .split(whereSeparator: \.isNewline)
            .suffix(limit)
            .map(String.init)
    }

    private func launchAgentLabel(for serverURL: URL) -> String? {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let launchAgentPath = home
            .appendingPathComponent("Library/LaunchAgents/com.arnav.minecraft.paper.plist")
            .path
        guard FileManager.default.fileExists(atPath: launchAgentPath) else {
            return nil
        }
        if serverURL.path.contains("minecraftserverlocal") {
            return "com.arnav.minecraft.paper"
        }
        return nil
    }
}
