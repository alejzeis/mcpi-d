module mcpid.net.login;

import draklib.protocol.packet;
import draklib.bytestream;

import cerealed;

import mcpid.net.network;

enum LoginStatus {
	STATUS_OK = 0,
	STATUS_SERVER_OUTDATED = 1,
	STATUS_CLIENT_OUTDATED = 2
}

struct LoginPacketS {
	ushort usernameLen;
	@ArrayLength("usernameLen") byte[] usernameBytes;
	uint protocol1;
	uint protocol2;
}

struct LoginStatusPacketS {
	uint status;
}

class LoginPacket : Packet {
	string username;
	uint protocol1;
	uint protocol2;

	override {
		protected void _encode(ref ByteStream stream) {
			stream.writeStrUTF8(username);
			stream.writeUInt(protocol1);
			stream.writeUInt(protocol2);
		}
		
		protected void _decode(ref ByteStream stream) {
			username = stream.readStrUTF8();
			protocol1 = stream.readUInt();
			protocol2 = stream.readUInt();
		}
		
		ubyte getID() {
			return LOGIN; 
		}
		
		uint getSize() {
			return cast(uint) (11 + (cast(byte[]) username).length);
		}
	}
}

class LoginStatusPacket : Packet {
	uint status;
	
	override {
		protected void _encode(ref ByteStream stream) {
			stream.writeUInt(status);
		}
		
		protected void _decode(ref ByteStream stream) {
			status = stream.readUInt();
		}
		
		ubyte getID() {
			return LOGIN_STATUS;
		}
		
		uint getSize() {
			return 5;
		}
	}
}

class StartGamePacket : Packet {
	uint seed;
	uint unknown;
	uint gamemode;
	uint entityId;
	float x;
	float y;
	float z;

	override {
		protected void _encode(ref ByteStream stream) {
			stream.writeUInt(seed);
			stream.writeUInt(unknown);
			stream.writeUInt(gamemode);
			stream.writeUInt(entityId);

		}
		
		protected void _decode(ref ByteStream stream) {

		}
		
		ubyte getID() {
			return LOGIN_STATUS;
		}
		
		uint getSize() {
			return 5;
		}
	}
}