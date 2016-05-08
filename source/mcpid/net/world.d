module mcpid.net.world;

import cerealed;

import mcpid.net.network;

struct AdventureSettingsPacket {
	ubyte pid = ADVENTURE_SETTINGS;
	int flags;
}

struct ChatPacket {
	ubyte pid = CHAT;
	string message;
}