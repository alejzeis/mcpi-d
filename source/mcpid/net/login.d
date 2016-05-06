module mcpid.net.login;

import mcpid.net.mcpacket;
import mcpid.net.packetstream;

class LoginPacket : Packet {
	string username;
	uint protocol1;
	uint protocol2;

	override {
		protected void _encode(ref PacketStream stream) {
			stream.writeStrUTF8(username);
			stream.writeUInt(protocol1);
			stream.writeUInt(protocol2);
		}
		
		protected void _decode(ref PacketStream stream) {
			username = stream.readStrUTF8();
			protocol1 = stream.readUInt();
			protocol2 = stream.readUInt();
		}
		
		ubyte getID() {
			return LOGIN_PACKET;
		}
		
		uint getSize() {
			return cast(uint) 11 + ((cast(ubyte[]) (username)).length);
		}
	}
}