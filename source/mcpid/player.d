module mcpid.player;

import mcpid.net.network;
import mcpid.net.login;
import mcpid.net.entity;
import mcpid.net.world;
import mcpid.world.entity;
import mcpid.server;
import mcpid.util;

import draklib.bytestream;

import cerealed;

import std.conv;

/// Represents a Player on the server
class Player : Entity {
	private shared string ip;
	private shared ushort port;

	private shared MinecraftPiServer server;

	private shared string username;
	private shared bool loggedIn = false;

	this(shared MinecraftPiServer server, shared string ip, shared ushort port) {
		super(64f, 64f, 64f);
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
				sgp.entityId = entityId;
				sgp.x = this.x;
				sgp.y = this.y;
				sgp.z = this.z;
				sendPacket(cast(shared) encodeStruct(sgp));
				break;
			case READY:
				sendMessage("This server is running " ~ SOFTWARE ~ " " ~ SOFTWARE_VERSION);
				AdventureSettingsPacket asp = AdventureSettingsPacket();
				asp.flags = 0;
				asp.flags |= 0x20; //nametags
				sendPacket(cast(shared) encodeStruct(asp));
			
				SetEntityDataPacket sedp = SetEntityDataPacket();
				sedp.entityId = entityId;
				sedp.metadata = getMetadata();
				sendPacket(cast(shared) encodeStruct(sedp));
				
				spawned = true;
				synchronized (server.playerLock) {
					foreach (player; server.players) { //TODO: parallel?
						if(player.getUsername() == username) continue;
						player.spawnTo(this);
						spawnTo(player);
					}	
				}
				break;
			default:
				break;
		}
	}
	
	shared void sendMessage(string message) {
		ChatPacket cp = ChatPacket();
		cp.message = message;
		sendPacket(cast(shared) encodeStruct(cp));
	}

	shared void close(in string reason, in bool notify = true) {
		if(notify) {
			server.getLogger().logInfo(username ~ " [" ~ getIdent(ip, port) ~ "] disconnected: " ~ reason);
			server.broadcastMessage(username ~ " has disconnected from the server.");
		}
	}
	
	shared string getUsername() {
		return username;
	}
	
	shared bool isLoggedIn() {
		return loggedIn;
	}
}