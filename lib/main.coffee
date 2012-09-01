exec    = require('child_process').exec
api     = require('../lib/api.coffee')
log     = console.log

execute = (cmd, cb) ->
  callback = (error, response) ->
    cb(error, response) if cb?
    # log the track
    if /play/.test cmd
      logTrack()

  exec "osascript -e 'tell app \"Rdio\" to #{cmd}'", (err, sin, sout) ->
    callback err, sin.replace(/\n/, '')

# log the current track to the console
logTrack = ->
  # the correct track data lags after a new track starts
  setTimeout (() ->
    execute 'name of the current track & " / " & artist of the current track', (err, sout) ->
      log "Playing: #{sout.replace(/\n/, '')}"), 500

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
    else
      type = args[0]
      query = args.slice(1).join(' ')
      if query is ''
        log "please provide the name of an #{type}"
        return

      if type is 'more'
        execute 'get the artist of the current track', (err, response) ->
          api.search response, ['artist'], (err, data) ->
            execute "play source \"#{data.result.results[0].topSongsKey}\""
      else if type is 'collection'
        api.getCollection (error, key) ->
          execute "play source \"#{key}\""
      else if type is 'album'
        api.getObjectInCollection 'album', query, (error, album) ->
          execute "play source \"#{album.albumKey}\""
      else if type is 'track'
        api.getObjectInCollection 'track', query, (error, track) ->
          execute "play source \"#{track.key}\""
      else
        # play an artists radio station
        if query is 'station'
          execute 'get the artist of the current track', (err, artist) ->
            api.getObjectInCollection 'artist', artist, (error, artist) ->
              execute "play source \"#{artist.radioKey ? artist.key}\""
        # plays an artists top tracks
        else
          api.getObjectInCollection 'artist', query, (error, artist) ->
            execute "play source \"#{artist.topSongsKey}\""

  # shorthand for playpause
  p: ->
    execute 'playpause'

  vol: (perc = 50) ->
    execute "set the sound volume to #{perc}"

  mute: ->
    @vol 0

  open: ->
    execute 'activate & reopen'

  help: ->
    log 'help'
