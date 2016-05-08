module mcpid.net.entity;

import cerealed;

import mcpid.net.network;

struct SetEntityDataPacket {
	ubyte pid = SET_ENTITY_DATA;
	uint entityId;
	@RestOfPacket byte[] metadata;
}

struct PlayerEquipmentPacket {
	ubyte pid = PLAYER_EQUIPMENT;
	uint entityId;
	short block;
	short meta;
}

struct AddPlayerPacket {
	ubyte pid = ADD_PLAYER;
	ulong clientID;
	string username;
	uint entityId;
	float x;
	float y;
	float z;
	@RestOfPacket byte[] metadata;
}