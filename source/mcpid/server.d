﻿module mcpid.server;

import draklib.util : InvalidOperationException;
import draklib.logging;
import draklib.server.raknetserver;
import draklib.server.serverinterface;

import mcpid.util;
import mcpid.player;

import core.thread;

import std.conv;
import std.exception;
import std.datetime;
import std.concurrency;

immutable string SOFTWARE = "mcpi-d";
immutable string SOFTWARE_VERSION = "1.0.0-alpha";
immutable string MCPI_VERSION = "0.1.1";
immutable uint MCPI_PROTOCOL = 9;

package class Lock { }

class MinecraftPiServer {
	private shared string bindIp;
	private shared ushort bindPort;
	private shared bool running = false;
	private shared bool crashed = false;
	private const Logger logger;

	private shared Player[string] players;
	private shared Lock playerLock;

	private shared ulong currentTick = 0;
	private shared uint nextTaskId = 0;
	private shared Task[uint] tasks;
	private shared Lock tasksLock;

	private Tid rakTid;

	package uint nextEntityId = 0;

	this(shared string bindIp, shared ushort bindPort) {
		this.bindIp = bindIp;
		this.bindPort = bindPort;

		logger = new LoggerImpl("MCPI-d");

		playerLock = cast(shared) new Lock();
		tasksLock = cast(shared) new Lock();

		shared ServerOptions options = ServerOptions();
		options.serverIdent = "MCCPP;MINECON;A mcpi-d server!";
		//options.serverIdent = "MCPE;A mcpi-d server!;" ~ to!string(MCPI_PROTOCOL) ~ ";" ~ MCPI_VERSION ~ "0;0";

		rakTid = spawn(&startRakServer, cast(shared) new LoggerImpl("DRakLib"), bindIp, bindPort, options);
		logger.logDebug("Started DRakLib thread");
	}

	void start() {
		enforce(!running, new InvalidOperationException("The server is already running!"));
		running = true;
		run();
	}

	void stop() {
		enforce(running, new InvalidOperationException("The server is not running!"));
		running = false;
	}

	private void run() {
		logger.logInfo("Starting " ~ SOFTWARE ~ " " ~ SOFTWARE_VERSION ~ " implementing MCPI " ~ MCPI_VERSION ~ " (protocol: " ~ to!string(MCPI_PROTOCOL) ~ ")");

		registerRepeatingTask(() {
				receiveTimeout(dur!("msecs")(1), &this.handleSessionOpen, &this.handleSessionClose, &this.handleSessionPacket);
			}, 1);

		StopWatch sw = StopWatch();
		while(running) {
			sw.reset();
			sw.start();
			try {
				doTick();
			} catch(Exception e) {
				logger.logError("Exception while ticking!");
				logger.logTrace(e.toString());
				running = false;
				crashed = true;
				break;
			}
			sw.stop();
			if(sw.peek().msecs > 50) { //20 TPS, 1000ms (1 second) / 20 = 50ms
				logger.logWarn("Can't keep up! Did the system time change or is the server overloaded? (took " ~ to!string(sw.peek().msecs) ~ "ms)");
			} else {
				Thread.sleep(dur!("msecs")(50 - sw.peek().msecs));
			}
		}
		if(crashed) logger.logError("The server has crashed!");
		logger.logInfo("Halting...");

		shutdownNetwork();

		logger.logInfo("Done");
	}

	private void doTick() {
		currentTick++;
		synchronized(tasksLock) {
			int[] toRemove;
			foreach(ref task; tasks) {
				if(task.lastRan + task.delay >= currentTick) {
					task.method();
					if(!task.repeat) {
						toRemove ~= task.taskId;
						continue;
					}
					task.lastRan = currentTick;
				}
			}
			foreach(id; toRemove) tasks.remove(id);
		}
	}

	void registerTask(void delegate() func, ulong runIn) {
		synchronized(tasksLock) {
			uint id = nextTaskId++;
			tasks[id] = Task(func, currentTick - runIn, runIn, id, false);
		}
	}

	void registerRepeatingTask(void delegate() func, ulong interval) {
		synchronized(tasksLock) {
			uint id = nextTaskId++;
			tasks[id] = Task(func, currentTick, interval, id, true);
		}
	}

	private void handleSessionOpen(SessionOpenMessage m) {
		synchronized (playerLock) {
			string ident = getIdent(m.ip, m.port);

			if(ident in players) return;

			logger.logDebug("Session opened from: " ~ ident);
			players[ident] = cast(shared) new Player(cast(shared) this, m.ip, m.port);
		}

	}

	private void handleSessionClose(SessionCloseMessage m) {
		string ident = getIdent(m.ip, m.port);
		logger.logDebug("Session closed from: " ~ ident);
		synchronized (playerLock) {
			if(!(ident in players)) return;

			players[ident].close(m.reason, true);
			players.remove(ident);
		}
	}

	private void handleSessionPacket(SessionReceivePacketMessage m) {
		string ident = getIdent(m.ip, m.port);
		synchronized(playerLock) {
			if(ident in players) {
				players[ident].handlePacket(cast(byte[]) m.payload);
			}
		}
	}

	private void shutdownNetwork() {
		//TODO: Kick players
		logger.logInfo("Stopping RakNet Server...");
		send(rakTid, StopServerMessage()); //Stop DRakLib

		bool stopped = false;
		receiveTimeout(dur!("seconds")(5), (ServerStoppedMessage m) {
				logger.logDebug("RakNet Server stopped.");
				stopped = true;
			});
		if(!stopped) logger.logWarn("Could not stop RakNet server, continuing shutdown...");
	}

	shared bool hasCrashed() {
		return crashed;
	}

	bool hasCrashed_noShare() {
		return cast(bool) crashed;
	}

	shared Logger getLogger() {
		return cast(Logger) logger;
	}
}

package void startRakServer(shared Logger logger, shared string bindIp, shared ushort bindPort, shared ServerOptions options) {
	RakNetServer server = new RakNetServer(ownerTid, cast(Logger) logger, cast(ushort) bindPort, cast(string) bindIp, cast(ServerOptions) options);
	server.start();
}