module app;

import mcpid.server;

/// Main function called by the D runtime
int main() {

	MinecraftPiServer server = new MinecraftPiServer("0.0.0.0", 19132);
	server.start();

	return server.hasCrashed_noShare() ? 1 : 0;
	
	/*
	import mcpid.net.network;
	import draklib.bytestream;
	import std.stdio;
	auto m = Metadata!string(MetadataType.STRING, "hello");
	alias intA = int[];
	ByteStream bs = ByteStream.alloc(1024);
	bs.write(writeMetadataEntry(1, Metadata!short(MetadataType.SHORT, cast(short) 300)));
	bs.write(writeMetadataEntry(16, Metadata!byte(MetadataType.BYTE, cast(byte) 0)));
	bs.write(writeMetadataEntry(17, Metadata!intA(MetadataType.INT_ARRAY, [0, 0, 0])));
	bs.writeUByte(0x7F); //End char
	writeln(bs.getBuffer()[0..bs.getPosition()]);
	
	return 0;
	*/
	/*
	import mcpid.net.login;
	import mcpid.net.network;
	import cerealed;
	import std.stdio;
	auto ceralizer = Cerealizer();
	ceralizer ~= LoginStatusPacketS(LOGIN_STATUS, LoginStatus.STATUS_CLIENT_OUTDATED);
	writeln(ceralizer.bytes);
	
	auto decerealiser = Decerealiser(cast(ubyte[]) [0x00, 0x04, 0x00, 0x00, 0x00]);
	writeln(decerealiser.value!LoginStatusPacketS);
	return 0;
	*/
}