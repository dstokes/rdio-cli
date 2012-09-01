# Rdio-CLI
Rrdio-CLI is a cli interface to the rdio desktop app for Mac.

## Installation
* Clone it
* Get yourself an rdio api key
* Create a config.json file in the root of the project with:
```
  { "key": "rdio-api-key"
  , "secret": "shh-secret-key"
  }
```

## Commands
Command              | Description
-------------------- | -------------------------
play                 | Play the currently selected track
play artist _artist_ | Play an artist from your collection
play album _album_   | Play an album from your collection
play track _track_   | Play a track from your collection
play collection      | Play your collections station
play artist station  | Play the current artists station
play heavy rotation  | Play your networks heavy rotation station
pause                | Pause playback
current              | Display info about the current track
next                 | Play the next track in the queue
prev                 | Play the previous track in the queue
vol _percentage_     | Change the volume
mute                 | Set volume to 0
p                    | Shorthand playpause toggle

* This module is still under heavy development and is equipped with all kinds of fancy bugs
