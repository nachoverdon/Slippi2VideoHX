package s2v;

import haxe.Json;
import sys.io.File;

typedef Cfg = {
	var melee: String;
	var obs: ObsConfig;
	var dolphin: String;
	var replays: String;
	var recursive: Bool;
	var obsOptions: ObsConfig;
}

typedef ObsConfig = {
	var exe: String;
	var port: String;
	var password: String;
	@:optional var profile: Null<String>;
	@:optional var scene: Null<String>;
	@:optional var videos: String;
	@:optional var rename: Bool;
	@:optional var restructure: Bool;
	@:optional var kill: Bool;
}

typedef ReplayCommFile = {
    var replay: String;
	@:optional var mode: String;
    @:optional var isRealTimeMode: Bool;
    @:optional var queue: Array<ReplayInfo>;
}

typedef ReplayInfo = {
	var path: String;
	var startFrame: Int;
	var lastFrame: Int;
}

class FileHandler {
    public static function readConfig(): Cfg {
        // TODO: Support cmd args? Sys.args() -> [];
		try {
        	var cfg: Cfg = Json.parse(File.getContent('config.json'));
			return cfg;
		} catch (e: Dynamic) {
			throw '[ERROR] Error parsing `config.json`. Make sure the data ' +
			'is correct.\n\t$e';
		}
    }

    public static function setReplay(replayPath: String): Void {
        var commFile: ReplayCommFile = {
			replay: replayPath
		};
		try {
			File.saveContent('s2v.json', Json.stringify(commFile));
		} catch (e: Dynamic) {
			throw '[ERROR] Error writing comm file `s2v.json`. Make sure the ' +
			'file is not read only, being used by other app, etc.\n\t$e';
		}
    }
}