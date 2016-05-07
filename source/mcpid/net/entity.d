module mcpid.net.entity;

import cerealed;

import mcpid.net.network;

struct AddPlayerPacket {
	ubyte pid = ADD_PLAYER;
	ulong clientID;
	string username;
	uint entityId;
	float x;
	float y;
	float z;
	ubyte end = 0x7F;
	@NoCereal byte[] metadata;
}