# Slippi2Video
![](https://i.imgur.com/OHvmaBV.png)

Script to convert Project Slippi replays into video using OBS


# Requires
* **Windows**.
* [**Project Slippi desktop app**](https://github.com/project-slippi/slippi-desktop-app/releases). Comes with a custom version of Dolphin, select this one when setting up your `config.json`. Configure Dolphin as you like. If the changes are not getting saved, check that the folder is not read only or that you have permissions. The script assumes that Dolphin is running at a constant framerate of 60 FPS, so desyncs may occur if the frames drop.
* [**OBS**](https://obsproject.com/) installed. Also you need to configure OBS the way you want to record the game, so create a scene and add Dolphin as source, etc., and add that info to the `config.json` file or set the `profile` and `scene` to `null` and the script will use the last selected profile/scene as target.
* [**OBS Websocket**](https://github.com/Palakis/obs-websocket/releases) installed and configured to match the settings in the `config.json` file.
* **Launch Slippi2Video.exe**, configure it with the paths to the replays folder, Dolphin.exe (Slippi), Super Smash Bros. Melee NTSC 1.02 version .iso and your OBS executable, as well as the OBS Websocket data and press Start. Alternatively, you can fill `config.json` and execute `S2V.exe`.

`config.json` should look like this (without comments):
```js
{
    // Path to Super Smash Bros. Melee NTSC 1.02 .iso.
    "melee": "Z:\\Games\\GAME ISOs\\Melee 1.02.iso",
    // Path to the replays folder with the .slp files.
    "replays": "C:\\Users\\bazoo\\SlippiReplays",
    // Path to Slippi Dolphin.exe
    "dolphin": "C:\\Users\\bazoo\\AppData\\Roaming\\Slippi Launcher\\dolphin\\Dolphin.exe",
    // Search folders within the replays folder.
    "recursive": true,
    "obs": {
        // Path to obs64.exe or obs32.exe.
        "exe": "C:\\Program Files\\obs-studio\\bin\\64bit\\obs64.exe",
        // OBS Websocket info (OBS > Tools > Websocket server settings).
        "port": "4444",
        "password": "slippi2video",
        // Path to the folder where the videos will be stored.
        "videos": "Z:\\Other\\Videos",
        // OBS Scene/profile options.
        // Set to "" to use the default.
        // NOT IMPLEMENTED YET
        "profile": "",
        // Set to "" to use the default.
        // NOT IMPLEMENTED YET
        "scene": "Slippi"
        // Renames the video files with the name from the .slp files. If a video
        // with the same name already exists, it will append a long number to
        // the name to avoid conflicts.
        "rename": true,
        // Sort the video files with the same structure that the replays folder has.
        // Ex: /SlippiReplays/Station1/replay1.slp -> /*obsVideos*/Station1/replay1.mp4
        // NOT IMPLEMENTED YET
        "restructure": true,
        // Shutdown OBS after processing all the replays.
        // NOT IMPLEMENTED YET
        "kill": true,
    }
}
```

# Build
Requires:
* Haxe 4 rc2
* hxcpp
* slippihx, haxe-ws, openfl, lime, haxeui-core and haxeui-openfl libraries
