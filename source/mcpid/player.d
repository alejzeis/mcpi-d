module mcpid.player;

import mcpid.server;
import mcpid.util;

/// Represents a Player on the server
class Player {
	private shared string ip;
	private shared ushort port;

	private shared MinecraftPiServer server;

	private shared string username;

	this(shared MinecraftPiServer server, shared string ip, shared ushort port) {
		this.server = server;
		this.ip = ip;
		this.port = port;
	}

	shared void handlePacket(byte[] data) {
		import std.format;
		server.getLogger().logDebug("Got packet: " ~ format("%02X", data[0]));
		switch(cast(ubyte) data[0]) {
			case 0x82:

				break;
			default:
				break;
		}
	}

	shared void close(in string reason, in bool notify = true) {
		if(notify) server.getLogger().logInfo(username ~ " [" ~ getIdent(ip, port) ~ "] disconnected: " ~ reason);
		//TODO: broadcast chat
	}
}