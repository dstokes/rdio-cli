exec    = require('child_process').exec
api     = require('../lib/api.coffee')
log     = console.log

execute = (cmd, cb) ->
  exec "osascript -e 'tell app \"Rdio\" to #{cmd}'", (err, sin, sout) ->
    cb(err, sin.replace(/\n/, '')) if cb?

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
      logTrack()
    else
      type = args[0]
      query = args.slice(1).join(' ')

      if type is 'more'
        execute 'get the artist of the current track', (err, response) ->
          api.search response, ['artist'], (err, data) ->
            execute "play source \"#{data.result.results[0].topSongsKey}\""
            logTrack()
      else if type is 'collection'
        api.getCollection (error, key) ->
          execute "play source \"#{key}\""
          logTrack()
      else if type is 'album'
        api.getAlbum query, (error, album) ->
          execute "play source \"#{album.albumKey}\""
          logTrack()
      else if type is 'track'
        api.getTrack query, (error, track) ->
          execute "play source \"#{track.key}\""
          logTrack()
      else
        # play an artists radio station
        if query is 'station'
          execute 'get the artist of the current track', (err, artist) ->
            api.getArtist artist, (error, artist) ->
              execute "play source \"#{artist.radioKey ? artist.key}\""
              logTrack()
        # plays an artists top tracks
        else
          api.getArtist query, (error, artist) ->
            execute "play source \"#{artist.topSongsKey}\""
            logTrack()

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
