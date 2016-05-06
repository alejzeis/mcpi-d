module mcpid.player;

import mcpid.net.network;
import mcpid.net.login;
import mcpid.server;
import mcpid.util;

import draklib.protocol.packet;

import cerealed;

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

	shared void sendPacket(Packet packet) {
		byte[] data;
		packet.encode(data);

		server.sendPacket(ip, port, cast(shared) data);
	}

	shared void sendPacketS(T)(T value) {
		auto cerealizer = Cerealizer();
		cerealizer ~= value;

		server.sendPacket(ip, port, cast(shared byte[]) cerealizer.bytes.dup);
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

				//LoginStatusPacket lsp = new LoginStatusPacket();
				LoginStatusPacketS lsp = LoginStatusPacketS();
				if(lp.protocol1 != MCPI_PROTOCOL || lp.protocol2 != MCPI_PROTOCOL) {
					server.getLogger().logDebug("Disconnecting " ~ lp.username ~": invalid protocol(s): " ~ to!string(lp.protocol1) ~ ", " ~ to!string(lp.protocol2));

					if(lp.protocol1 > MCPI_PROTOCOL || lp.protocol2 > MCPI_PROTOCOL) {
						lsp.status = LoginStatus.STATUS_SERVER_OUTDATED;
					} else {
						lsp.status = LoginStatus.STATUS_CLIENT_OUTDATED;
					}

					//sendPacket(lsp);
					sendPacketS(lsp);
					close("Invalid protocol(s): " ~ to!string(lp.protocol1) ~ ", " ~ to!string(lp.protocol2));
					return;
				}
				username = lp.username;
				entityId = cast(shared) server.nextEntityId++;

				server.getLogger().logInfo(username ~ " logged in with entity Id: " ~ to!string(entityId));

				lsp.status = LoginStatus.STATUS_OK;
				//sendPacket(lsp);
				sendPacketS(lsp);
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