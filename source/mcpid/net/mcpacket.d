module mcpid.net.mcpacket;

import draklib.util : NotImplementedException;

import mcpid.net.packetstream;

immutable ubyte LOGIN_PACKET = 0x82;

class Packet {
	void encode(out byte[] data) {
		PacketStream stream = PacketStream.alloc(getSize());
		stream.writeUByte(getID());
		_encode(stream);
		data = stream.getBuffer().dup;
		stream.clear();
	}

	void decode(byte[] data) {
		PacketStream stream = PacketStream.wrap(data);
		stream.skip(1); // ID
		_decode(stream);
	}
	
	protected void _encode(ref PacketStream stream) {
		throw new NotImplementedException("Encoding has not been implemented by underlying class.");
	}
	
	protected void _decode(ref PacketStream stream) {
		throw new NotImplementedException("Decoding has not been implemented by underlying class.");
	}
	
	abstract uint getSize();
	abstract ubyte getID();
}