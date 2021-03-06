
# # Config
#
# *Configuration traversal.*
#
# This class allows us to wrap and subsequently get, set, and check the
# existence of values in a configuration tree. The configuration tree may be
# traversed with colons, e.g. `parent:child:grandchild`. Supposing we have a
# configuration structure:
#
#     configuration =
#         visible: true
#         child:
#             id: 200
#             tag: null
#
# We may wrap and interact with it as follows:
#
#     wrapped = new Config configuration
#     wrapped.get 'visible'
#
# `true`
#
#     wrapped.set 'child:name', 'Billy'
#     wrapped.get 'child'
#
# `{ id: 200, name: 'Billy' }`
#
#     wrapped.has 'child:id'
#
# `true`
#
#     wrapped.has 'child:thing'
#
# `false`
#
#     # Works with null values.
#     wrapped.has 'child:tag'
#
# `true`
#
class Config

  constructor: ->

    @_config = {}

  mergeIn: (config) ->

    merge = (defaults, toMerge) ->

      merged = {}

      if defaults and 'object' is typeof defaults

        for key in Object.keys defaults

          merged[key] = defaults[key]

      for key in Object.keys toMerge

        if 'object' isnt typeof toMerge[key] or not toMerge[key]

          merged[key] = toMerge[key]

        else

          if defaults[key]

            merged[key] = merge defaults[key], toMerge[key]

          else

            merged[key] = toMerge[key]

      return merged

    @_config = merge @_config, config

  # ### .get
  #
  # *Get a value by key.*
  #
  # * (string) `key` - The key to look up, e.g. parent:child:grandchild
  get: (key) ->

    current = @_config
    current = current?[part] for part in key.split ':'
    current

  # ### .getOrCreate
  #
  # *Get a value by key if it exists, or create it if it doesn't already.*
  #
  # * (string) `key` - The key to look up, e.g. parent:child:grandchild
  # * (any) `value` - The value to set if the key has to be created
  getOrCreate: (key, value) ->

    parts = key.split ':'
    lastPart = parts.pop()

    c = @_config
    for part in parts
      c = if c[part]? then c[part] else c[part] = {}
    if c[lastPart]? then c[lastPart] else c[lastPart] = value

  # ### .has
  #
  # *Check whether a key exists.*
  #
  # * (string) `key` - The key to look up, e.g. parent:child:grandchild
  has: (key) ->

    current = @_config
    for part in key.split ':'
      return false unless part of current
      current = current[part]

    return true

  # ### .set
  #
  # *Set a value by key.*
  #
  # * (string) `key` - The key to look up, e.g. parent:child:grandchild
  # * (any) `value` - The value to store at the key location.
  set: (key, value) ->

    [parts..., last] = key.split ':'
    current = @_config
    for part in parts
      current = (current[part] ?= {})

    current[last] = value

module.exports = config = new Config()

config.Config = Config

config.mergeIn require './defaults'

# Merge from config file.
config.mergeFromFile = (filename) ->
  require('avo/fs').readYamlResource(filename).then (O) -> config.mergeIn O
