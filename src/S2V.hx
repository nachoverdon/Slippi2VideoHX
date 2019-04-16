import haxe.io.Path;
import sys.thread.Thread;
import sys.io.Process;
import s2v.FileHandler;
import s2v.WebSocketObs;

class S2V {
	static var cfg: Config;
	static var ws: WebSocketObs;
	static var dolphinProcess: Process;
	static var obsProcess: Process;

	static function main() {
		onClose();
		cfg = FileHandler.readConfig();

		var replays = FileHandler.findReplays(cfg.replays, cfg.recursive);

		Sys.println('Replays found: ${replays.length}');

		if (replays.length == 0) return;

		launchDolphin();
		launchObs();

		// This should be enough time to load Dolphin and OBS.
		Sys.sleep(5);

		ws = new WebSocketObs('localhost', cfg.obs.port, cfg.obs.password, true);

		var oldRecFolder: String;

		function onReady(message: String) {
			Sys.println('Connected.');

			ws.getRecordingFolder();
			if (cfg.obs.videos != null) ws.setRecordingFolder(cfg.obs.videos);

			// For each replay, load slippi and record video until the replay
			// is finished.
			for (replay in replays) recordVideo(replay);
			ws.setRecordingFolder(oldRecFolder);

			Sys.sleep(2);
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

		function onMessageString(message: String) {
			var req = haxe.Json.parse(message);

			oldRecFolder = Reflect.field(req, 'rec-folder');
		}

		ws.connect(onReady, onError, onMessageString);
	}

	// TODO: Not killing OBS process.
	static function killProcesses(): Void {
		Sys.println('Closing...');
		ws.stopRecording();
		Sys.sleep(.2);
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

	static function recordVideo(replayPath: String): Void {
		var frames = FileHandler.getFrames(replayPath);
		// 2 seconds is aprox. the time it takes for the Game! screen to end.
		// 116 frames? makes sense coz 116 + 124 = 240, 240 / 60 = 4 seconds.
		var seconds: Float = (frames / 60) + (116 / 60);

		var path = new Path(replayPath);
		Sys.println('Recording replay ${path.file}.${path.ext}...');

		// TODO: Replace this with a signal from Dolphin. as well as
		// ws.stopRecording() (stdout/stderr? socket?)
		// communicateWithDolphin(ws.startRecording, ws.stopRecording);
		// As soon as it connects, starts the replay and records.
		FileHandler.setReplay(replayPath);
		ws.startRecording();


		// Waits for the duration of the replay and then stops it.
		Sys.sleep(seconds);
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

	static function communicateWithDolphin(onGameStart: Void -> Void, onGameEnd: Void -> Void): Void {
		Thread.create(function() {
			// Sys.println('Duration:\t[FRAMES: ${frames}]\t[SECONDS: $seconds]');
			// Sys.println('lastFrame:\t[FRAMES: ${frames - 124}]\t[SECONDS: ${seconds - (124 / 60)}]');

			while (true) {
				var out = '';

				try {
					out = dolphinProcess.stdout.readLine();
				} catch (e: haxe.io.Eof) {
					break;
				}

				switch (out) {
					case '[GAME_START]': onGameStart();
					case '[GAME_END]': onGameEnd();
				}

			}

		});
	}

	static function onClose(): Void {
		Thread.create(function() {

			while (true) {
				var out = '';

				try {
					out = Sys.stdin().readLine();
				} catch (e: haxe.io.Eof) {
					break;
				}

				if (out == '!CLOSE') killProcesses();
			}

		});
	}
}