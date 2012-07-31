debug = require('debug')('vfs:test')
fs = require 'fs'

{ EventEmitter } = require 'events'


class Monitor extends EventEmitter

  constructor: (@vfs, @path) ->
    @vfs.monitors.push this

  close: ->
    if (index = @vfs.monitors.indexOf this) >= 0
      @vfs.monitors.splice index, 1

  includes: (candidate) ->
    (candidate == @path) or (candidate.substr(0, @path.length + 1) == @path + '/')


class TestVFS

  constructor: ->
    @files = {}
    @monitors = []

  normalize: (path) ->
    fs.normalize(path)

  exists: (path, callback) ->
    @files.hasOwnProperty(path)

  put: (path, body) ->
    @files[path] = body
    @changed path

  changed: (path) ->
    for monitor in @monitors
      if monitor.includes(path)
        monitor.emit 'change', path

  watch: (path) ->
    new Monitor(this, path)


module.exports = TestVFS

