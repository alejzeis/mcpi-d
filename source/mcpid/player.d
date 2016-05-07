module mcpid.player;

import mcpid.net.network;
import mcpid.net.login;
import mcpid.net.entity;
import mcpid.server;
import mcpid.util;

import cerealed;

import std.conv;

/// Represents a Player on the server
class Player {
	private shared string ip;
	private shared ushort port;

	private shared MinecraftPiServer server;

	private shared string username;
	private shared uint entityId;
	private shared bool loggedIn = false;

	this(shared MinecraftPiServer server, shared string ip, shared ushort port) {
		this.server = server;
		this.ip = ip;
		this.port = port;
	}

	shared void sendPacket(shared byte[] data) {
		server.sendPacket(ip, port, data);
	}

	shared void handlePacket(byte[] data) {
		switch(cast(ubyte) data[0]) {
			case LOGIN:
				if(loggedIn) return;
				LoginPacket lp = decodeStruct!LoginPacket(data);

				LoginStatusPacket lsp = LoginStatusPacket();
				if(lp.protocol1 != MCPI_PROTOCOL || lp.protocol2 != MCPI_PROTOCOL) {
					server.getLogger().logDebug("Disconnecting " ~ lp.username ~": invalid protocol(s): " ~ to!string(lp.protocol1) ~ ", " ~ to!string(lp.protocol2));

					if(lp.protocol1 > MCPI_PROTOCOL || lp.protocol2 > MCPI_PROTOCOL) {
						lsp.status = LoginStatus.STATUS_SERVER_OUTDATED;
					} else {
						lsp.status = LoginStatus.STATUS_CLIENT_OUTDATED;
					}

					sendPacket(cast(shared) encodeStruct(lsp));
					close("Invalid protocol(s): " ~ to!string(lp.protocol1) ~ ", " ~ to!string(lp.protocol2));
					return;
				}
				username = lp.username;
				entityId = cast(shared) server.nextEntityId++;

				server.getLogger().logInfo(username ~ " logged in with entity Id: " ~ to!string(entityId));
				loggedIn = true;

				lsp.status = LoginStatus.STATUS_OK;
				sendPacket(cast(shared) encodeStruct(lsp));
				
				StartGamePacket sgp = StartGamePacket();
				sgp.seed = 123456; //Random seed
				sgp.unknown = 0;
				sgp.gamemode = 1;
				//sgp.entityId = entityId;
				sgp.entityId = 1;
				sgp.x = 64f;
				sgp.y = 64f;
				sgp.z = 64f;
				sendPacket(cast(shared) encodeStruct(sgp));
				break;
			case READY:
				AddPlayerPacket app = AddPlayerPacket();
				app.clientID = 0;
				app.entityId = 0;
				app.username = "ameme";
				app.x = 69f;
				app.y = 64f;
				app.z = 69f;
				server.getLogger().logDebug(username ~ " has spawned.");
				//sendPacket(cast(shared) encodeStruct(app));
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