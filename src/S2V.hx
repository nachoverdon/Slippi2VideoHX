import haxe.io.Path;
import cpp.vm.Thread;
import sys.io.Process;
import sys.FileSystem;
import s2v.FileHandler;
import s2v.WebSocketObs;

class S2V {
	static var cfg: Config;
	static var ws: WebSocketObs;
	static var dolphinProcess: Process;
	static var obsProcess: Process;

	static function main() {
		cfg = FileHandler.readConfig();

		var replays = findReplays(cfg.replays);

		Sys.println('Replays found: ${replays.length}');

		if (replays.length == 0) return;

		launchDolphin();
		launchObs();

		// This should be enough time to load Dolphin and OBS.
		Sys.sleep(5);

		ws = new WebSocketObs('localhost', cfg.obs.port, cfg.obs.password, true);

		function onReady(message: String) {
			Sys.println('Connected.');
			// For each replay, load slippi and record video until the replay
			// is finished.
			for (replay in replays) convert(replay);

			// Closes the websocket, Dolphin and OBS
			killProcesses();
		}

		function onError(error: String) {
			Sys.println(
				'[ERROR] OBS Websocket error:\n\t$error\n' +
				'Please, check if your OBS Websocket settings on OBS Studio ' +
				'(Tools > Websocket server settings) and your config.json ' +
				'file match.'
			);
			Sys.exit(0);
		}

		ws.connect(onReady, onError);
	}

	static function findReplays(folder: String): Array<String> {
		var replays: Array<String> = new Array<String>();

		for (file in FileSystem.readDirectory(folder)) {
			var absPath = '$folder\\$file';

			if (cfg.recursive && FileSystem.isDirectory(absPath)) {
				replays = replays.concat(findReplays(absPath));
				continue;
			}

			if (Path.extension(file) == 'slp') replays.push('$folder\\$file');
		}

		return replays;
	}

	// TODO: Not killing OBS process.
	static function killProcesses(): Void {
		Sys.println('Closing...');
		ws.close();
		dolphinProcess.kill();
		obsProcess.kill();
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



	static function convert(replayPath: String): Void {
		var seconds = Math.ceil(FileHandler.getFrames(replayPath) / 60);
		recordVideo(replayPath, seconds);
	}

	static function recordVideo(replayPath: String, seconds: Int): Void {
		var path = new Path(replayPath);
		Sys.println('Recording replay ${path.file}.${path.ext}...');

		// As soon as it connects, starts the replay and records.
		FileHandler.setReplay(replayPath);
		// TODO: Replace this with a signal from Dolphin. as well as
		// ws.stopRecording() (stdout/stderr? socket?)

		Thread.create(function() {

			while (true) {
				var out = '';
				try {
					out = dolphinProcess.stdout.readLine();
					Sys.println(out);
				} catch (e: haxe.io.Eof) {
					break;
				}
			}
		});
		ws.startRecording();

		// Waits for the duration of the replay and then stops it.
		// 2 seconds is aprox. the time it takes for the Game! screen to end.
		// 116 frames? makes sense coz 116 + 124 = 240, 240 / 60 = 4 seconds.
		Sys.sleep(seconds + (116 / 60));
		ws.stopRecording();
		Sys.sleep(2);
	}

	static function launchDolphin(): Void {
		FileHandler.setReplay('');

		dolphinProcess = new Process(cfg.dolphin,
			['-i', 's2v.json', '-b', '-e', cfg.melee]
		);
	}

	static function launchObs(): Void {
		var cwd = Sys.getCwd();
		var obsPath = ~/[\\\/]obs\d+\.exe/i.replace(cfg.obs.exe, '');
		Sys.setCwd(obsPath);
		obsProcess = new Process(cfg.obs.exe);
		Sys.setCwd(cwd);
	}
}