module app;

import mcpid.server;

/// Main function called by the D runtime
int main() {
	MinecraftPiServer server = new MinecraftPiServer("0.0.0.0", 19132);
	server.start();

	return server.hasCrashed_noShare() ? 1 : 0;
}