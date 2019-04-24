package s2v;

import haxe.Json;
import haxe.Timer;
import haxe.io.Bytes;
import haxe.crypto.Base64;
import haxe.crypto.Sha256;
import haxe.net.WebSocket;
import sys.thread.Thread;

typedef RequestField = {
    var name: String;
    var value: String;
}

class WebSocketObs {
    var ws: WebSocket;
    var timer: Timer;
    var ip: String;
    var port: String;
    var pw: String;
    var isRecording: Bool = false;

    public function new(?ip: String = 'localhost', ?port: String = '4444',
    ?pw: String = 'slippi', ?debug = false) {
        this.ip = ip;
        this.port = port;
        this.pw = pw;

        timer = new Timer(60);

        ws = WebSocket.create('ws://$ip:$port', ['echo-protocol'], null, debug);
    }

    public function connect(onReady: String -> Void, onError: String -> Void,
        onMessageString: String -> Void) {
        ws.onopen = function() {
            sendRequest(ws, 'GetAuthRequired');
        };

        ws.onmessageString = function(message: String) {
            var res: Dynamic = Json.parse(message);
            var msgId: String = Reflect.field(res, 'message-id');

            if (res.status == 'error') throw 'Auth error: ${res.error}';

            switch (msgId) {
                case 'GetAuthRequired':
                    auth(res);
                case 'Authenticate':
                    Thread.create(function() {
                        onReady(message);
                    });
                case 'StartRecording':
                    isRecording = true;
                    trace('Recording...');
                case 'StopRecording':
                    isRecording = false;
                    trace('Stopped recording.');
                case 'SetRecordingFolder':
                    trace('Recording folder set.');
                case 'GetRecordingFolder':
                    onMessageString(message);
                case 'Shutdown':
                    trace('Exiting...');
                default:
                    return;
            }
        }

        ws.onerror = function(error: String) {
            onError(error);
        }

        ws.onmessageBytes = function(bytes: Bytes) {
            trace('[onmessagebytes]');
        }

        ws.onclose = function() {
            trace('Closing...');
        }

        timer.run = function() { ws.process(); }
    }

    public function close() {
        timer.stop();
        ws.close();
    }

    public function startRecording() {
        if (isRecording) return;

        sendRequest(ws, 'StartRecording');
    }

    public function stopRecording() {
        if (!isRecording) return;

        sendRequest(ws, 'StopRecording');
    }

    public function setRecordingFolder(folder: String) {
        trace('Setting recording folder to $folder...');
        sendRequest(ws, 'SetRecordingFolder', null, [{
            name: 'rec-folder', value: folder
        }]);
    }

    public function getRecordingFolder(): Void {
        sendRequest(ws, 'GetRecordingFolder');
    }

    public function shutdown() sendRequest(ws, 'Shutdown');

    function auth(res: Dynamic) {
        if (res.authRequired) {
            var secretHash = Sha256.make(Bytes.ofString(pw + res.salt));
            var secret = Base64.encode(secretHash);
            var authResponseHash = Sha256.make(Bytes.ofString(secret + res.challenge));
            var authResponse = Base64.encode(authResponseHash);

            sendAuth(ws, 'Authenticate', authResponse);
        }
    }

    static function sendAuth(ws: WebSocket, msgId: String, auth: String): Void {
        sendRequest(ws, 'Authenticate', msgId, [{name: 'auth', value: auth}]);
    }

    static function sendRequest(ws: WebSocket, reqType: String, ?msgId: String = null, ?fields: Array<RequestField>): Void {
        var req = {
            "request-type": reqType,
            "message-id": msgId == null ? reqType : msgId
        };

        if (fields != null) {
            for (f in fields)
                Reflect.setField(req, f.name, f.value);
        }

        ws.sendString(Json.stringify(req));
    }
}

