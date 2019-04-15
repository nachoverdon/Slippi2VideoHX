package s2v;

import haxe.Json;
import haxe.Timer;
import haxe.io.Bytes;
import haxe.crypto.Base64;
import haxe.crypto.Sha256;
import haxe.net.WebSocket;

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

    public function new(?ip: String = 'localhost', ?port: String = '4444',
    ?pw: String = 'slippi', ?debug = false) {
        this.ip = ip;
        this.port = port;
        this.pw = pw;

        timer = new Timer(100);

        ws = WebSocket.create('ws://$ip:$port', ['echo-protocol'], null, debug);
    }

    public function connect(onReady: String -> Void, onError: String -> Void) {
        ws.onopen = function() {
            sendRequest('GetAuthRequired');
        };

        ws.onmessageString = function(message: String) {
            var res: Dynamic = readResponse(message);
            var msgId: String = Reflect.field(res, 'message-id');

            if (res.status == 'error') throw 'Auth error: ${res.error}';

            switch (msgId) {
                case 'GetAuthRequired':
                    auth(res);
                case 'Authenticate':
                    onReady(message);
                case 'StartRecording':
                    trace('Recording...');
                case 'StopRecording':
                    trace('Stopped recording.');
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
        // timer.stop();
        // Timer.delay(function() {
            timer.stop();
            ws.close();
        // }, 100);
    }

    public function startRecording() sendRequest('StartRecording');

    public function stopRecording() sendRequest('StopRecording');

    public function shutdown() sendRequest('Shutdown');

    function auth(res: Dynamic) {
        if (res.authRequired) {
            var secretHash = Sha256.make(Bytes.ofString(pw + res.salt));
            var secret = Base64.encode(secretHash);
            var authResponseHash = Sha256.make(Bytes.ofString(secret + res.challenge));
            var authResponse = Base64.encode(authResponseHash);

            sendAuth('Authenticate', authResponse);
        }
    }

    function sendAuth(msgId: String, auth: String): Void {
        sendRequest('Authenticate', msgId, [{name: 'auth', value: auth}]);
    }

    function readResponse(message: String): Dynamic {
        return Json.parse(message);
    }

    function sendRequest(reqType: String, ?msgId: String = null, ?fields: Array<RequestField>): Void {
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

