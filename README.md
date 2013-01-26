# Rdio-CLI
A NodeJS cli interface to the rdio desktop app for Mac.

## Installation
```shell
git clone git@github.com:dstokes/rdio-cli.git
```
* Get yourself an rdio api key
* Create a config.json file in the root of the project with:
```
  { "key": "rdio-api-key"
  , "secret": "shh-secret-key"
  }
```

## Repl / GUI
Running the <code>rdio</code> command without any arguments will drop you
into 'repl' mode.  From here you can execute all of the shorthand commands
with a single keystroke, or hit 'x' to drop into readline mode where
complex commands like <code>> play artist thrice</code> can be executed.
![Screenshot](http://f.cl.ly/items/2r2G3w2n3G2Z273C2v3O/Screen%20Shot%202013-01-25%20at%2011.21.18%20PM.png)

## Commands
Command              | Description
-------------------- | -------------------------
play                 | Play the currently selected track
play artist _artist_ | Play an artist from your collection
play album _album_   | Play an album from your collection
play track _track_   | Play a track from your collection
play list _list_     | Play a playlist
play collection      | Play your collections station
play artist station  | Play the current artists station
play heavy rotation  | Play your networks heavy rotation station
next                 | Play the next track in the queue
prev                 | Play the previous track in the queue
p                    | Shorthand playpause toggle
n                    | Shorthand next
P                    | Shorthand previous

* This module is still under heavy development and is equipped with all kinds of fancy bugs
