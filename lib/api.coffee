request = require('request')
path    = require('path')
oauth   = require('oauth').OAuth
fs      = require('fs')
log     = console.log
config  = require(path.join __dirname, '..', 'config.json')

accessToken = 'http://api.rdio.com/oauth/access_token'
requestToken = 'http://api.rdio.com/oauth/request_token'
oa = new oauth(requestToken, accessToken, config.key, config.secret, '1.0', 'oob', 'HMAC-SHA1')

# write to the config file
writeConfig  = (config) ->
  file = path.join __dirname, '..', 'config.json'
  fs.writeFile file, JSON.stringify(config), (err) ->
    log err if err?

getToken = (cb) ->
  callback = cb ? () ->
  if config.oauthAccessToken
    callback()
    return

  oa.getOAuthRequestToken (err, token, secret, result) ->
    if err?
      callback error, {}
      return

    config.oauthToken = token
    config.oauthTokenSecret = secret
    url = "#{result.login_url}?oauth_token=#{token}"

    process.stdin.resume()
    process.stdout.write "visit: #{url}\nEnter your pin: "
    process.stdin.once 'data', (data) ->
      oa.getOAuthAccessToken token, secret, data.toString().trim(), (error, tok, sec, result) ->
        config.oauthAccessToken = tok
        config.oauthAccessTokenSecret =  sec
        writeConfig config
        callback()


module.exports =
  # make a request to the rdio api
  request: (method, params, cb) ->
    params = params ? {}
    params.method = method
    callback = cb ? () ->

    getToken (err) ->
      oa.post(
        'http://api.rdio.com/1/',
        config.oauthAccessToken,
        config.oauthAccessTokenSecret,
        params,
        'application/x-www-form-urlencoded',
        callback
      )

  search: (query = '', types = [], cb) ->
    params = { query: query, types: types.join(',') }
    @request 'search', params, (error, data) ->
      json = JSON.parse data
      cb(error, json) if cb?

  getCollection: (cb) ->
    if config?.user?.collectionKey
      cb null, config.user.collectionKey
      return

    @request 'currentUser', { extras: 'collectionKey' }, (error, data) ->
      config.user = JSON.parse(data).result
      writeConfig config
      cb error, config.user.collectionKey

  getObjectInCollection: (type, query, cb) ->
    method = "get#{type.charAt(0).toUpperCase() + type.slice(1)}sInCollection"
    @request method, { query: query }, (error, data) ->
      obj = JSON.parse(data).result[1]
      cb error, obj
