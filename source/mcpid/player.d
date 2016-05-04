module mcpid.player;

import mcpid.server;

/// Represents a Player on the server
class Player {
	private shared string ip;
	private shared ushort port;

	private shared MinecraftPiServer server;


	this(shared MinecraftPiServer server, shared string ip, shared ushort port) {
		this.server = server;
		this.ip = ip;
		this.port = port;
	}
}