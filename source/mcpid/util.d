module mcpid.util;

import draklib.logging;

import std.conv;
import std.stdio;
import std.datetime;

class LoggerImpl : Logger {
	private const string name;

	this(in string name) {
		this.name = name;
	}

	override {
		const void logDebug(in string message) {
			writeln("[" ~ getTime() ~ "] [" ~ name ~ "/DEBUG]: " ~ message);
		}
		
		const void logInfo(in string message) {
			writeln("[" ~ getTime() ~ "] [" ~ name ~ "/INFO]: " ~ message);
		}
		
		const void logWarn(in string message) {
			writeln("[" ~ getTime() ~ "] [" ~ name ~ "/WARN]: " ~ message);
		}
		
		const void logError(in string message) {
			writeln("[" ~ getTime() ~ "] [" ~ name ~ "/ERROR]: " ~ message);
		}
		
		const void logTrace(in string trace) {
			import std.array;
			foreach(string segment; split(trace, "\n")) {
				writeln("[" ~ getTime() ~ "] [" ~ name ~ "/TRACE]: " ~ segment);
			}
		}
	}

	private const string getTime() {
		return to!string(Clock.currTime.day) ~ "/" ~ to!string(Clock.currTime.month) ~ "/" ~ to!string(Clock.currTime.year) ~ " " ~ to!string(Clock.currTime.hour) ~ ":" ~ to!string(Clock.currTime.minute) ~ ":" ~ to!string(Clock.currTime.second);
	}

	const string getName() {
		return name;
	}
}