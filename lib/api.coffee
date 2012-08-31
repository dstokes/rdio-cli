request = require('request')
oauth   = require('oauth').OAuth
exec    = require('child_process').exec
config  = require('../config.json')

oa = new oauth(
  '', '', config.key, config.secret, '1.0', '', 'HMAC-SHA1'
)

module.exports =
  # make a request to the rdio api
  request: (method, params, cb) ->
    params = params ? {}
    params.method = method
    callback = cb ? () ->
    oa.post(
      'http://api.rdio.com/1/',
      '', '',
      params,
      'application/x-www-form-urlencoded',
      callback
    )

  search: (query = '', types = [], cb) ->
    params = { query: query, types: types.join(',') }
    @request 'search', params, (error, data) ->
      json = JSON.parse data
      cb(error, json) if cb?
