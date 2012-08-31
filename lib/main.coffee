request = require('request')
oauth   = require('oauth').OAuth
exec    = require('child_process').exec
config  = require('../config.json')
log     = console.log

oa = new oauth(
  '', '', config.key, config.secret, '1.0', '', 'HMAC-SHA1'
)

execute = (cmd, cb) ->
  exec "osascript -e 'tell app \"Rdio\" to #{cmd}'", (err, sin, sout) ->
    # give rdio some time to actually start the track
    setTimeout (() -> cb(err, sin) if cb?), 250

makeRequest = (method, params, cb) ->
  params = params ? {}
  params.method = method
  oa.post(
    'http://api.rdio.com/1/',
    '', '',
    params,
    'application/x-www-form-urlencoded',
    cb
  )

# log the current track to the console
logTrack = ->
  execute 'name of the current track & " / " & artist of the current track', (err, sout) ->
    log "Playing: #{sout.replace(/\n/, '')}"

module.exports =
  pause: -> execute 'pause'

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
      makeRequest 'search', { query: args.join(' '), types: 'artist' }, (error, data) ->
        json = JSON.parse data
        execute "play source \"#{json.result.results[0].topSongsKey}\""

  help: ->
    log 'help'
