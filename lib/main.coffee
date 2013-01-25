exec    = require('child_process').exec
api     = require('../lib/api.coffee')
log     = console.log
stdin   = process.stdin
stdout  = process.stdout

delay = (ms, func) -> setTimeout func, ms

execute = (cmd, cb) ->
  callback = (error, response) ->
    cb(error, response) if cb?
    # log the track
    if /play/.test cmd
      logTrack()

  exec "osascript -e 'tell app \"Rdio\" to #{cmd}'", (err, sin, sout) ->
    callback err, sin.replace(/\n/, '')

clear = ->
  process.stdout.write '\u001B[2J\u001B[0;0f'

# log the current track to the console
logTrack = (shouldClear) ->
  # the correct track data lags after a new track starts
  setTimeout (() ->
    execute 'name of the current track & " / " & artist of the current track', (err, sout) ->
      clear() if shouldClear
      log "Playing: #{sout.replace(/\n/, '')}"), 500

module.exports =
  pause: ->
    execute 'pause'

  current: (cb = ->) ->
    @getTrack (info) ->
      cb(info)
      log("Playing: #{info}")

  getTrack: (cb) ->
    delay 500, () ->
      execute 'name of the current track & " / " & artist of the current track', (err, stdout) ->
        cb(stdout.replace /\n/, '')

  next: ->
    execute 'next track'
    logTrack(@isRepl)

  prev: ->
    execute 'previous track'
    logTrack(@isRepl)

  play: (args...) ->
    if args.length is 0
      execute 'play'
    else
      type = args[0]
      query = args.slice(1).join(' ')

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
      else if type is 'heavy' and query is 'rotation'
        api.getHeavyRotation (error, key) ->
          execute "play source \"#{key}\""
      else if type is 'list'
        regex = new RegExp(query, 'i')
        api.getPlaylists (error, lists) ->
          owned = lists.owned
          playlist = list for list in owned when regex.test(list.name)
          execute "play source \"#{playlist.key}\""
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
  p: (cb) ->
    execute 'playpause', cb

  vol: (perc = 50) ->
    execute "set the sound volume to #{perc}"

  mute: ->
    @vol 0

  open: ->
    execute 'activate & reopen'

  help: ->
    log 'help'

  # aliases
  P: (cb) -> @prev(cb)
  n: (cb) -> @next(cb)
  r: (cb) -> @current(cb)
