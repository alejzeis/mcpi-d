module mcpid.net.network;

import cerealed;

import draklib.bytestream;

import std.system;

byte[] encodeStruct(T)(T s) @safe {
	auto c = Cerealizer();
	c ~= s;
	return cast(byte[]) c.bytes.dup; 
}

T decodeStruct(T)(ref byte[] data) @safe {
	auto d = Decerealizer(data);
	return d.value!T;
}

byte[] writeMetadataEntry(ubyte bottom, Metadata!byte meta) @trusted {
	ByteStream bs = ByteStream.alloc(2, Endian.littleEndian);
	bs.writeUByte(cast(ubyte) ((meta.type << 5) & (0xE0 | bottom)));
	bs.writeByte(meta.val);
	return bs.getBuffer().dup;
}

byte[] writeMetadataEntry(ubyte bottom, Metadata!short meta) @trusted {
	ByteStream bs = ByteStream.alloc(3, Endian.littleEndian);
	bs.writeUByte(cast(ubyte) ((meta.type << 5) & (0xE0 | bottom)));
	bs.writeShort(meta.val);
	return bs.getBuffer().dup;
}

byte[] writeMetadataEntry(ubyte bottom, Metadata!(int[]) meta) {
	ByteStream bs = ByteStream.alloc(cast(uint) (1 + (4 * meta.val.length)), Endian.littleEndian);
	bs.writeUByte(cast(ubyte) ((meta.type << 5) & (0xE0 | bottom)));
	foreach(val; meta.val) {
		bs.writeInt(val);
	}
	return bs.getBuffer().dup;
}

struct Metadata(T) {
	ubyte type;
	T val;
}

enum MetadataType {
	BYTE = 0,
	SHORT = 1,
	INT = 2,
	FLOAT = 3,
	STRING = 4,
	UNKNOWN1 = 5, //Not sure about this one
	INT_ARRAY = 6
	
}

immutable ubyte LOGIN = 0x82;
immutable ubyte LOGIN_STATUS = 0x83;
immutable ubyte READY = 0x84;
immutable ubyte CHAT = 0x85;
immutable ubyte SET_TIME = 0x86;
immutable ubyte START_GAME = 0x87;
immutable ubyte ADD_MOB = 0x88;
immutable ubyte ADD_PLAYER = 0x89;
//immutable ubyte REMOVE_PLAYER = 0x8a;
immutable ubyte ADD_ENTITY = 0x8c;
immutable ubyte REMOVE_ENTITY = 0x8d;
immutable ubyte ADD_ITEM_ENTITY = 0x8e;
immutable ubyte TAKE_ITEM_ENTITY = 0x8f;
immutable ubyte MOVE_ENTITY = 0x90;
immutable ubyte MOVE_ENTITY_POSROT = 0x93;
immutable ubyte MOVE_PLAYER = 0x94;
immutable ubyte PLACE_BLOCK = 0x95;
immutable ubyte REMOVE_BLOCK = 0x96;
immutable ubyte UPDATE_BLOCK = 0x97;
immutable ubyte ADD_PAINTING = 0x98;
immutable ubyte EXPLOSION = 0x99;
immutable ubyte LEVEL_EVENT = 0x9a;
//immutable ubyte TILE_EVENT = 0x9b;
immutable ubyte ENTITY_EVENT = 0x9c;
immutable ubyte REQUEST_CHUNK = 0x9d;
immutable ubyte CHUNK_DATA = 0x9e;
immutable ubyte PLAYER_EQUIPMENT = 0x9f;
immutable ubyte PLAYER_ARMOR_EQUIPMENT = 0xa0;
immutable ubyte INTERACT = 0xa1;
immutable ubyte USE_ITEM = 0xa2;
immutable ubyte PLAYER_ACTION = 0xa3;
immutable ubyte HURT_ARMOR = 0xa5;
immutable ubyte SET_ENTITY_DATA = 0xa6;
immutable ubyte SET_ENTITY_MOTION = 0xa7;
immutable ubyte SET_HEALTH = 0xa8;
immutable ubyte SET_SPAWN_POSITION = 0xa9;
immutable ubyte ANIMATE = 0xaa;
immutable ubyte RESPAWN = 0xab;
immutable ubyte SEND_INVENTORY = 0xac;
immutable ubyte DROP_ITEM = 0xad;
immutable ubyte CONTAINER_OPEN = 0xae;
immutable ubyte CONTAINER_CLOSE = 0xaf;
immutable ubyte CONTAINER_SET_SLOT = 0xb0;
//immutable ubyte CONTAINER_SET_DATA = 0xb1;
//immutable ubyte CONTAINER_SET_CONTENT = 0xb2;
//immutable ubyte CONTAINER_ACK = 0xb3;
immutable ubyte CLIENT_MESSAGE = 0xb4;
immutable ubyte SIGN_UPDATE = 0xb5;
immutable ubyte ADVENTURE_SETTINGS = 0xb6;