package s2v;

import haxe.Json;
import sys.io.File;
import sys.FileSystem;
import haxe.io.Path;
import slippihx.SlpDecoder;

typedef Config = {
	var melee: String;
	var obs: ObsConfig;
	var dolphin: String;
	var replays: String;
	var recursive: Bool;
}

typedef ObsConfig = {
	var exe: String;
	var port: String;
	var password: String;
	var profile: String;
	var scene: String;
	var videos: String;
	var rename: Bool;
	var restructure: Bool;
	var kill: Bool;
}

typedef ReplayCommFile = {
    var replay: String;
	@:optional var mode: String;
	@:optional var commandId: String;
    @:optional var isRealTimeMode: Bool;
    @:optional var queue: Array<ReplayInfo>;
    @:optional var outputOverlayFiles: Bool;
	@:optional var startFrame: Int;
	@:optional var endFrame: Int;
}

typedef ReplayInfo = {
	var path: String;
	@:optional var startFrame: Int;
	@:optional var endFrame: Int;
}

class FileHandler {
    public static function readConfig(): Config {
        // TODO: Support cmd args? Sys.args() -> [];
		try {
        	var cfg: Config = Json.parse(File.getContent('config.json'));
			return cfg;
		} catch (e: Dynamic) {
			throw '[ERROR] Error parsing `config.json`. Make sure the data ' +
			'is correct and the structure is valid JSON and doesn\'t have ' +
			'comments.\n\t$e';
		}
    }

    public static function setReplay(replayPath: String): Void {
		var commFile: ReplayCommFile;

		if (replayPath == '') {
			commFile = { replay: '' };
		} else {
			commFile = {
				replay: replayPath,
				commandId: '${Sys.time()}',
				endFrame: getFrames(replayPath)
			};
		}

		try {
			File.saveContent('s2v.json', Json.stringify(commFile));
		} catch (e: Dynamic) {
			throw '[ERROR] Error writing comm file `s2v.json`. Make sure the ' +
			'file is not read only, being used by other app, etc.\n\t$e';
		}
    }

	public static function getFrames(replayPath: String): Int {
		try {
			var slp = SlpDecoder.fromFile(replayPath);
			var duration: Int = slp.metadata.duration;
			slp = null;
			return duration;
		} catch (e: Dynamic) {
			throw 'Error parsing the replay $replayPath.\nMake sure the file ' +
			'is not being used by other app.\n\t$e';
		}
	}

	public static function findReplays(folder: String, ?recursive: Bool = false): Array<String> {
		var replays: Array<String> = new Array<String>();

		for (file in FileSystem.readDirectory(folder)) {
			var absPath = '$folder\\$file';

			if (recursive && FileSystem.isDirectory(absPath)) {
				replays = replays.concat(findReplays(absPath, recursive));
				continue;
			}

			if (Path.extension(file) == 'slp') replays.push('$folder\\$file');
		}

		return replays;
	}

	public static function tempDir(path: String): String {
		var name = 's2v_${Date.now().getTime()}';
		var dir = '$path\\$name';
		FileSystem.createDirectory(dir);
		return dir;
	}

	public static function moveFiles(oldPath: String, newPath: String, ?name: String = null): Void {
		for (file in FileSystem.readDirectory(oldPath)) {
			var ext = Path.extension('$oldPath\\$file');
			var newFile = '$newPath\\';
			newFile += name == null ? '$file' : '$name';
			if (FileSystem.exists('$newFile.$ext')) {
				newFile += '_${Date.now().getTime()}';
			}
			FileSystem.rename('$oldPath\\$file', '$newFile.$ext');

		}
	}

	public static function removeDir(path: String) {
		if (FileSystem.exists(path)) FileSystem.deleteDirectory(path);
	}
}