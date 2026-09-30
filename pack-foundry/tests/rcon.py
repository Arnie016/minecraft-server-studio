"""Minimal local-only RCON harness; never prints or stores authentication values."""
import socket
import struct
from pathlib import Path


class Rcon:
    def __init__(self, server_dir):
        server_dir = Path(server_dir)
        if not (server_dir / "SIGNALKEEPERS_TEST_WORLD").exists():
            raise RuntimeError("Refusing to operate outside a marked disposable test world")
        props = dict(line.split("=", 1) for line in (server_dir / "server.properties").read_text().splitlines() if "=" in line and not line.startswith("#"))
        if props.get("server-ip") != "127.0.0.1":
            raise RuntimeError("Only a loopback test server is supported")
        self.sock = socket.create_connection(("127.0.0.1", int(props["rcon.port"])), timeout=10)
        self.seq = 1
        self.send(3, props["rcon.password"])
        ident, _, _ = self.recv()
        if ident == -1:
            raise RuntimeError("RCON authentication failed")

    def read(self, size):
        data = b""
        while len(data) < size:
            part = self.sock.recv(size - len(data))
            if not part:
                raise ConnectionError("RCON closed")
            data += part
        return data

    def recv(self):
        size, = struct.unpack("<i", self.read(4))
        data = self.read(size)
        ident, kind = struct.unpack("<ii", data[:8])
        return ident, kind, data[8:-2].decode()

    def send(self, kind, value):
        self.seq += 1
        data = struct.pack("<ii", self.seq, kind) + value.encode() + b"\0\0"
        self.sock.sendall(struct.pack("<i", len(data)) + data)

    def command(self, value):
        self.send(2, value)
        return self.recv()[2]


if __name__ == "__main__":
    import sys
    r = Rcon(sys.argv[1])
    print(r.command(" ".join(sys.argv[2:])))
