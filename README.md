# Slippi2Video
Script to convert Project Slippi replays into video using OBS

# Requires
* **Windows**.
* [**Project Slippi desktop app**](https://github.com/project-slippi/slippi-desktop-app/releases). Comes with a custom version of Dolphin, select this one when setting up your `config.json`. Configure Dolphin as you like. If the changes are not getting saved, check that the folder is not read only or that you have permissions. The script assumes that Dolphin is running at a constant framerate of 60 FPS, so desyncs may occur if the frames drop.
* [**OBS**](https://obsproject.com/) installed. Also you need to configure OBS the way you want to record the game, so create a scene and add Dolphin as source, etc. as well as...
* [**OBS Websocket**](https://github.com/Palakis/obs-websocket/releases) installed and configured to match the settings in the `config.json` file.
* **Fill `config.json`** with the paths to the replays folder, Dolphin.exe (Slippi), Super Smash Bros. Melee NTSC 1.02 version .iso and your OBS executable, as well as the OBS Websocket data.

`config.json` should look like this (without comments):
```js
{
    // Path to obs64.exe or obs32.exe
    "obs": "C:\\Program Files\\obs-studio\\bin\\64bit\\obs64.exe",
    // Path to Super Smash Bros. Melee NTSC 1.02 .iso
    "melee": "Z:\\Games\\GAME ISOs\\Melee 1.02.iso",
    // Path to the replays folder with the .slp files
    "replays": "C:\\Users\\bazoo\\SlippiReplays",
    // Path to Slippi Dolphin.exe
    "dolphin": "C:\\Users\\bazoo\\AppData\\Roaming\\Slippi Launcher\\dolphin\\Dolphin.exe",
    // OBS Websocket info (OBS > Tools > Websocket server settings)
    "obsws": {
        "port": "4444",
        "password": "slippi2video"
    },
    // Search folders within the replays folder.
    "recursive": true
}
```

* **Execute `s2v.exe`**.
* **Pray** for it to work.
