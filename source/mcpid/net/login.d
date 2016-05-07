module mcpid.net.login;

import cerealed;

import mcpid.net.network;

enum LoginStatus {
	STATUS_OK = 0,
	STATUS_SERVER_OUTDATED = 1,
	STATUS_CLIENT_OUTDATED = 2
}

struct LoginPacket {
	ubyte pid = LOGIN;
	string username; // Short prefix, then bytes
	uint protocol1;
	uint protocol2;
}

struct LoginStatusPacket {
	ubyte pid = LOGIN_STATUS;
	uint status;
	
	/*
	import std.stdio;
	void accept(C)(auto ref C cereal) {
		if(typeid(cereal) == typeid(Cerealiser)) {
			writeln("Cerealizer");
		}
		if(typeid(cereal) == typeid(Decerealiser)) {
			writeln("Decerealizer");
		}
	}
	*/
}

struct ReadyPacket {
	ubyte pid = READY;
	ubyte status;
}

struct StartGamePacket {
	ubyte pid = START_GAME;
	uint seed;
	uint unknown;
	uint gamemode;
	uint entityId;
	float x;
	float y;
	float z;
}