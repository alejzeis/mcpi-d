module app;

import mcpid.server;

/// Main function called by the D runtime
int main() {

	MinecraftPiServer server = new MinecraftPiServer("0.0.0.0", 19132);
	server.start();

	return server.hasCrashed_noShare() ? 1 : 0;
	
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