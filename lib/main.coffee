exec    = require('child_process').exec
api     = require('../lib/api.coffee')
log     = console.log

execute = (cmd, cb) ->
  exec "osascript -e 'tell app \"Rdio\" to #{cmd}'", (err, sin, sout) ->
    # give rdio some time to actually start the track
    setTimeout (() -> cb(err, sin) if cb?), 350

# log the current track to the console
logTrack = ->
  execute 'name of the current track & " / " & artist of the current track', (err, sout) ->
    log "Playing: #{sout.replace(/\n/, '')}"

module.exports =
  pause: ->
    execute 'pause'

  current: ->
    logTrack()

  next: ->
    execute 'next track'
    logTrack()

  prev: ->
    execute 'previous track'
    logTrack()

  play: (args...) ->
    if args.length is 0
      execute 'play'
      logTrack()
    else
      if args[0] is 'more'
        execute 'get the artist of the current track', (err, response) ->
          api.search response, ['artist'], (err, data) ->
            execute "play source \"#{data.result.results[0].topSongsKey}\""
            logTrack()
      else if args[0] is 'collection'
        api.getCollection (error, key) ->
          execute "play source \"#{key}\""
          logTrack()
      else
        # setup a queing system for `play more`
        api.search args.join(' '), ['artist'], (err, data) ->
          execute "play source \"#{data.result.results[0].topSongsKey}\""
          logTrack()

  # shorthand for playpause
  p: -> execute 'playpause'

  vol: (perc = 50) ->
    execute "set the sound volume to #{perc}"

  mute: ->
    @vol 0

  test: ->
    api.test()

  help: ->
    log 'help'
