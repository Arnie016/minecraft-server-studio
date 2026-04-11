import Foundation

enum ServerProvisionError: Error, LocalizedError {
    case message(String)

    var errorDescription: String? {
        switch self {
        case .message(let message):
            return message
        }
    }
}

struct ServerProvisionRequest: Hashable {
    let sourceServerURL: URL
    let name: String
    let port: Int
    let memoryMB: Int
    let cloneMode: StudioPluginCloneMode
}

struct ServerProvisioner {
    var baseDirectory: URL {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("MinecraftServerStudio", isDirectory: true)
            .appendingPathComponent("Servers", isDirectory: true)
    }

    func createServer(using request: ServerProvisionRequest) -> Result<URL, ServerProvisionError> {
        let fileManager = FileManager.default
        let destinationName = sanitizedFolderName(from: request.name)
        guard !destinationName.isEmpty else {
            return .failure(.message("Choose a name for the new server first."))
        }

        guard let sourceJar = firstMatchingJar(in: request.sourceServerURL) else {
            return .failure(.message("The selected source server does not have a Paper jar to clone."))
        }

        let destinationURL = baseDirectory.appendingPathComponent(destinationName, isDirectory: true)
        guard !fileManager.fileExists(atPath: destinationURL.path) else {
            return .failure(.message("A server named \(destinationName) already exists in \(baseDirectory.path)."))
        }

        do {
            try fileManager.createDirectory(at: destinationURL, withIntermediateDirectories: true)
            try fileManager.createDirectory(at: destinationURL.appendingPathComponent("plugins", isDirectory: true), withIntermediateDirectories: true)
            try fileManager.createDirectory(at: destinationURL.appendingPathComponent("logs", isDirectory: true), withIntermediateDirectories: true)

            let destinationJar = destinationURL.appendingPathComponent(sourceJar.lastPathComponent)
            try fileManager.copyItem(at: sourceJar, to: destinationJar)

            writeStartScript(into: destinationURL, jarName: destinationJar.lastPathComponent, memoryMB: request.memoryMB)
            writeEULA(into: destinationURL)
            writeServerProperties(into: destinationURL, serverName: request.name, port: request.port)
            writeNotes(into: destinationURL, request: request)
            try clonePlugins(from: request.sourceServerURL, into: destinationURL, cloneMode: request.cloneMode)
            return .success(destinationURL)
        } catch {
            return .failure(.message("Could not create the server: \(error.localizedDescription)"))
        }
    }

    private func sanitizedFolderName(from text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let lowered = trimmed.isEmpty ? "new-server" : trimmed.lowercased()
        return lowered
            .components(separatedBy: CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_")).inverted)
            .filter { !$0.isEmpty }
            .joined(separator: "-")
    }

    private func firstMatchingJar(in serverURL: URL) -> URL? {
        let fileManager = FileManager.default
        guard let files = try? fileManager.contentsOfDirectory(at: serverURL, includingPropertiesForKeys: nil) else {
            return nil
        }
        return files.first { url in
            let name = url.lastPathComponent.lowercased()
            return (name.hasPrefix("paper-") || name.hasPrefix("purpur-") || name.hasPrefix("spigot-") || name == "server.jar") &&
                name.hasSuffix(".jar")
        }
    }

    private func writeStartScript(into serverURL: URL, jarName: String, memoryMB: Int) {
        let memoryFloor = max(memoryMB / 2, 1024)
        let contents = """
        #!/usr/bin/env bash
        set -euo pipefail

        cd "$(dirname "$0")"
        java -Xms\(memoryFloor)M -Xmx\(memoryMB)M -jar "\(jarName)" nogui
        """
        let startScriptURL = serverURL.appendingPathComponent("start-paper.sh")
        try? contents.write(to: startScriptURL, atomically: true, encoding: .utf8)
        try? FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: startScriptURL.path)
    }

    private func writeEULA(into serverURL: URL) {
        let contents = """
        # Review the Minecraft EULA before setting this to true.
        eula=false
        """
        try? contents.write(to: serverURL.appendingPathComponent("eula.txt"), atomically: true, encoding: .utf8)
    }

    private func writeServerProperties(into serverURL: URL, serverName: String, port: Int) {
        let contents = """
        motd=\(serverName)
        enable-query=true
        server-port=\(port)
        difficulty=normal
        max-players=10
        online-mode=true
        allow-flight=true
        view-distance=10
        simulation-distance=10
        spawn-protection=0
        """
        try? contents.write(to: serverURL.appendingPathComponent("server.properties"), atomically: true, encoding: .utf8)
    }

    private func writeNotes(into serverURL: URL, request: ServerProvisionRequest) {
        let contents = """
        Minecraft Server Studio scaffolded this server.

        Name: \(request.name)
        Port: \(request.port)
        Memory: \(request.memoryMB) MB
        Plugin clone mode: \(request.cloneMode.title)

        Before first launch:
        1. Review eula.txt and set eula=true if you accept it.
        2. Review server.properties.
        3. Run ./start-paper.sh
        """
        try? contents.write(to: serverURL.appendingPathComponent("STUDIO-NOTES.txt"), atomically: true, encoding: .utf8)
    }

    private func clonePlugins(from sourceServerURL: URL, into destinationURL: URL, cloneMode: StudioPluginCloneMode) throws {
        guard cloneMode != .none else { return }

        let fileManager = FileManager.default
        let sourcePluginsURL = sourceServerURL.appendingPathComponent("plugins", isDirectory: true)
        let destinationPluginsURL = destinationURL.appendingPathComponent("plugins", isDirectory: true)
        let pluginFiles = try fileManager.contentsOfDirectory(at: sourcePluginsURL, includingPropertiesForKeys: nil)
            .filter { $0.pathExtension.lowercased() == "jar" }

        let filteredPlugins = pluginFiles.filter { pluginURL in
            switch cloneMode {
            case .none:
                return false
            case .creativeTooling:
                let name = pluginURL.lastPathComponent.lowercased()
                return name.contains("worldedit") ||
                    name.contains("acacia") ||
                    name.contains("coreprotect") ||
                    name.contains("griefprevention") ||
                    name.contains("citizens") ||
                    name.contains("auraskills")
            case .fullStack:
                return true
            }
        }

        for pluginURL in filteredPlugins {
            let targetURL = destinationPluginsURL.appendingPathComponent(pluginURL.lastPathComponent)
            try fileManager.copyItem(at: pluginURL, to: targetURL)
        }
    }
}
