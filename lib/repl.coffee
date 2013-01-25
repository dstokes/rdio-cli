stdin  = process.stdin
stdout = process.stdout
Emitter  = require('events').EventEmitter

class Repl extends Emitter
  start: ->
    stdin.resume()
    stdin.setEncoding 'utf8'
    stdin.setRawMode 'true'
    @clear()

    # emit events for each type of input
    stdin.on 'data', (input) =>
      return @stop() if input is '\u0003'

      if input is 'x'
        return @setReadline true

      if input.length > 1
        evt = 'line'
        @setReadline false
        @clear()

      @emit evt ? 'keypress', input

  stop: ->
    stdin.pause()
    stdin.setRawMode false
    @emit 'close'

  setReadline: (readline = true) ->
    if readline is true
      stdin.setRawMode false
      stdout.write '> '
    else
      stdin.setRawMode true

  clear: ->
    stdout.write '\u001B[2J\u001B[0;0f'

  write: (data) ->
    stdout.write data

module.exports = new Repl()
