import haxe.Json;
import sys.io.File;
import haxe.io.Path;
import sys.io.Process;
import sys.FileSystem;
import s2v.WebSocketObs;
import slippihx.SlpDecoder;


typedef Config = {
	var melee: String;
	var obs: String;
	var dolphin: String;
	var replays: String;
	var obsws: ObsWsConfig;
	var recursive: Bool;
}

typedef ObsWsConfig = {
	var port: String;
	var password: String;
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

class S2V {
	static var cfg: Config;
	static var ws: WebSocketObs;
	static var dolphinProcess: Process;
	static var obsProcess: Process;

	static function main() {
		readConfig();

		var replays = findReplays(cfg.replays);

		if (replays.length == 0) return;

		launchDolphin();
		launchObs();

		// This should be enough time to load Dolphin and OBS.
		Sys.sleep(5);

		ws = new WebSocketObs('localhost', cfg.obsws.port, cfg.obsws.password);

		function onReady(message: String) {
			trace('Connected.');
			// for each replay, load slippi and record video
			for (replay in replays) convert(replay);

			// Closes the websocket, Dolphin and OBS
			killProcesses();
		}

		function onError(error: String) {
			trace('[ERROR] There was an error while trying to connect to OBS Websocket\n$error');
			Sys.exit(0);
		}

		ws.connect(onReady, onError);
	}

	static function findReplays(folder: String): Array<String> {
		var replays: Array<String> = new Array<String>();

		for (file in FileSystem.readDirectory(folder)) {
			if (cfg.recursive && FileSystem.isDirectory(file)) {
				replays = replays.concat(findReplays('$folder\\$file'));
				continue;
			}

			if (Path.extension(file) == 'slp')
				replays.push('$folder\\$file');
		}

		trace('Replays found: ${replays.length}');

		return replays;
	}

	// TODO: Not killing OBS process.
	static function killProcesses(): Void {
		trace('Closing...');
		ws.close();
		dolphinProcess.kill();
		// obsProcess.kill();
		Sys.exit(0);

		// Not working
			// ws.shutdown();

			// Sys.command('taskkill /F /PID ${obsProcess.getPid()}');
			// Sys.command('taskkill /F /PID ${dolphinProcess.getPid()}');

		// This method works, but what if the user has multiple instances?
			// var p = new Path(cfg.dolphin);
			// Sys.command('taskkill /F /PID ${p.file}.exe');
			// p = new Path(cfg.obs);
			// Sys.command('taskkill /F /PID ${p.file}.exe');
	}

	static function readConfig(): Void {
		// TODO: Support cmd args? Sys.args() -> [];
		var file = File.read('config.json', true);
		var bytes = file.readAll();
		cfg = Json.parse(bytes.getString(0, bytes.length));
	}

	static function getFrames(replayPath: String): Int {
		try {
			var slp = SlpDecoder.fromFile(replayPath);
			var duration: Int = slp.metadata.duration;
			slp = null;
			return duration;
		} catch (e: Dynamic) {
			throw 'Error parsing the replay $replayPath';
		}
	}

	static function convert(replayPath: String): Void {
		var seconds = Math.ceil(getFrames(replayPath) / 60);
		recordVideo(replayPath, seconds);
	}

	static function recordVideo(replayPath: String, seconds: Int): Void {
		var path = new Path(replayPath);
		trace('Recording replay ${path.file}.${path.ext}...');

		// As soon as it connects, starts the replay and records.
		watchReplay(replayPath);
		// TODO: Replace this with a signal from Dolphin. as well as
		// ws.stopRecording() (stdout/stderr? socket?)
		ws.startRecording();

		// Waits for the duration of the replay and then stops it.
		// 2 seconds is aprox. the time it takes for the Game! screen to end.
		// 116 frames?
		Sys.sleep(seconds + 2);
		ws.stopRecording();
		Sys.sleep(2);
	}

	static function watchReplay(replayPath: String): Void {
		var commFile: ReplayCommFile = {
			replay: replayPath
		};
		File.saveContent('s2v.json', Json.stringify(commFile));
	}

	static function launchDolphin(): Void {
		watchReplay('');
		trace('"${cfg.dolphin}" -i s2v.json -b -e "${cfg.melee}"');
		dolphinProcess = new Process(cfg.dolphin,
			['-i', 's2v.json', '-b', '-e', cfg.melee]
		);
	}

	static function launchObs(): Void {
		var cwd = Sys.getCwd();
		var obsPath = ~/[\\\/]obs\d+\.exe/i.replace(cfg.obs, '');
		Sys.setCwd(obsPath);
		obsProcess = new Process(cfg.obs);
		Sys.setCwd(cwd);
	}
}