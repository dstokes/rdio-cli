request = require('request')
oauth   = require('oauth').OAuth
exec    = require('child_process').exec
config  = require('../config.json')
log     = console.log

oa = new oauth(
  '', '', config.key, config.secret, '1.0', '', 'HMAC-SHA1'
)

execute = (cmd) ->
  exec "osascript -e 'tell app \"Rdio\" to #{cmd}'", (err, sin, sout) ->
    log err if err?

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

module.exports =
  pause: -> execute 'pause'
  next: -> execute 'next track'
  prev: -> execute 'previous track'

  play: (args...) ->
    if args.length is 0
      execute 'play'
    else
      makeRequest 'search', { query: args.join(' '), types: 'artist' }, (error, data) ->
        json = JSON.parse data
        execute "play source \"#{json.result.results[0].topSongsKey}\""

  help: ->
    log 'help'
