module mcpid.player;

import mcpid.net.network;
import mcpid.net.login;
import mcpid.server;
import mcpid.util;

import std.conv;

/// Represents a Player on the server
class Player {
	private shared string ip;
	private shared ushort port;

	private shared MinecraftPiServer server;

	private shared string username;
	private shared uint entityId;

	this(shared MinecraftPiServer server, shared string ip, shared ushort port) {
		this.server = server;
		this.ip = ip;
		this.port = port;
	}

	shared void handlePacket(byte[] data) {
		debug {
			import std.string;
			server.getLogger().logDebug("Got packet: " ~ format("%02X", data[0]));
		}
		switch(cast(ubyte) data[0]) {
			case LOGIN:
				LoginPacket lp = new LoginPacket();
				lp.decode(data);
				if(lp.protocol1 != MCPI_PROTOCOL || lp.protocol2 != MCPI_PROTOCOL) {
					server.getLogger().logDebug("Disconnecting " ~ lp.username ~": invalid protocol(s): " ~ to!string(lp.protocol1) ~ ", " ~ to!string(lp.protocol2));
					//Login Status
					close("Invalid protocol(s): " ~ to!string(lp.protocol1) ~ ", " ~ to!string(lp.protocol2));
					return;
				}
				username = lp.username;
				entityId = cast(shared) server.nextEntityId++;

				server.getLogger().logInfo(username ~ " logged in with entity Id: " ~ to!string(entityId));
				//Login status
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