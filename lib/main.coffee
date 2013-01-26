exec    = require('child_process').exec
api     = require('../lib/api.coffee')
log     = console.log
stdin   = process.stdin
stdout  = process.stdout

Backbone = require 'backbone'
delay = (ms, func) -> setTimeout func, ms

class Rdio extends Backbone.Model
  initialize: () ->
    @fetchCurrentTrack()

    # setup aliases
    @p = @playpause
    @n = @next
    @P = @prev

  ###
  # Execute an applescript against the rdio api
  #
  # @param {string} cmd  the command to execute
  # @param {function} cb  the callback to execute on command success
  ###
  run: (cmd, callback) ->
    cb = (error, resp) ->
      callback(error, resp) if callback?
    exec "osascript -e 'tell app \"Rdio\" to #{cmd}'", (err, stdout, stderr) ->
      cb err, stdout.replace(/\n/, '')

  ###
  # Toggle play state
  ###
  playpause: ->
    @run 'playpause'
    delay 500, => @fetchCurrentTrack()

  ###
  # Play next track
  ###
  next: ->
    @run 'next track'
    delay 500, => @fetchCurrentTrack()

  ###
  # Play previous track
  ###
  prev: ->
    @run 'previous track'
    delay 500, => @fetchCurrentTrack()

  ###
  # Play an object
  ###
  play: (args...) ->
    self = @
    updateTrack = =>
      delay 500, => @fetchCurrentTrack()

    return @run('play') if args.length is 0

    type = args[0]
    query = args.slice(1).join(' ')

    switch type
      when 'more'
        @run 'get the artist of the current track', (err, resp) ->
          api.search resp, ['artist'], (err, data) ->
            self.run "play source \"#{data.result.results[0].topSongsKey}\"", updateTrack

      when 'collection'
        api.getCollection (error, key) =>
          @run "play source \"#{key}\"", updateTrack

      when 'album'
        api.getObjectInCollection 'album', query, (error, album) =>
          @run "play source \"#{album.albumKey}\"", updateTrack

      when 'track'
        api.getObjectInCollection 'track', query, (error, track) =>
          @run "play source \"#{track.key}\"", updateTrack

      when 'heavy'
        api.getHeavyRotation (error, key) =>
          @run "play source \"#{key}\"", updateTrack

      when 'list'
        regex = new RegExp(query, 'i')
        api.getPlaylists (error, lists) =>
          owned = lists.owned
          playlist = list for list in owned when regex.test(list.name)
          @run "play source \"#{playlist.key}\"", updateTrack

      else
        # play an artists radio station
        if query is 'station'
          @run 'get the artist of the current track', (err, artist) ->
            api.getObjectInCollection 'artist', artist, (error, artist) ->
              self.run "play source \"#{artist.radioKey ? artist.key}\"", updateTrack
        # plays an artists top tracks
        else
          api.getObjectInCollection 'artist', query, (error, artist) =>
            @run "play source \"#{artist.topSongsKey}\"", updateTrack

  ###
  # Get the current track information and update the model
  ###
  fetchCurrentTrack: ->
    cmd = "get the name of the current track " +
          "& \"|\" & artist of the current track " +
          "& \"|\" & album of the current track"

    @run cmd, (err, stdout) =>
      [track, artist, album] = stdout.split '|'
      @set { track: track, artist: artist, album: album }

module.exports = new Rdio()
