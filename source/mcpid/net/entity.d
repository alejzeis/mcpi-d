module mcpid.net.entity;

import cerealed;

import mcpid.net.network;

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


struct MovePlayerPacket {
	ubyte pid = MOVE_PLAYER;
	uint entityId;
	float x;
	float y;
	float z;
	float yaw;
	float pitch;
}

struct AnimatePacket {
	byte action;
	uint entityId;
}

struct UseItemPacket {
	ubyte pid = USE_ITEM;
	int x;
	int y;
	int z;
	int face;
	short block;
	byte meta;
	uint entityId;
	float fx;
	float fy;
	float fz;
}

struct RemoveEntityPacket {
	ubyte pid = REMOVE_ENTITY;
	uint entityId;
}

struct SetEntityDataPacket {
	ubyte pid = SET_ENTITY_DATA;
	uint entityId;
	@RestOfPacket byte[] metadata;
}