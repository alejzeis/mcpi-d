module mcpid.net.login;

import draklib.protocol.packet;
import draklib.bytestream;

import mcpid.net.network;

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