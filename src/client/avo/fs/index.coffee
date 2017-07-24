
Promise = require 'vendor/bluebird'
yaml = require 'vendor/js-yaml'

config = require 'avo/config'

readUri = (uri) ->

  new Promise (resolve, reject) ->

    if window?

      request = new window.XMLHttpRequest()
      request.open 'GET', uri
      request.onreadystatechange = ->

        if request.readyState is 4

          switch request.status

            # Work around for old node-webkit behavior.
            # See: https://github.com/rogerwang/node-webkit/commit/08c6ce5ff3fcf1b4df0aca1e717bb80d617214a2

            when 0, 200

              if request.responseText
                resolve request.responseText
              else
                reject new Error "Couldn't load resource: #{uri}"

            else
              reject new Error "Couldn't load resource: #{uri}"

      request.send()

    else

      fs = require 'fs'

      fs.readFile uri, (error, data) ->
        return reject error if error?

        resolve data

resourceCache = {}
exports.readResource = (uri) ->

  qualifiedUri = "#{config.get 'fs:resourcePath'}#{uri}"

  new Promise (resolve, reject) ->

    if resourceCache[qualifiedUri]?

      resolve resourceCache[qualifiedUri]

    else

      readUri(qualifiedUri).then((text) ->

        resolve resourceCache[qualifiedUri] = text

      ).catch reject

# Reads a JSON resource. Returns a promise to be resolved with the parsed
# JSON object.
exports.readJsonResource = (uri) ->

  @readResource(uri).then (O) ->

    try

      JSON.parse O

    catch error

      error.message = "Error parsing JSON at #{
        "#{config.get 'fs:resourcePath'}#{uri}"
      } -> #{
        error.message
      }"

      throw error

# Reads a YAML resource. Returns a promise to be resolved with the parsed
# YAML object.
exports.readYamlResource = (uri) ->

  @readResource(uri).then (O) ->

    try

      yaml.safeLoad O

    catch error

      error.message = "Error parsing YAML at #{
        "#{config.get 'fs:resourcePath'}#{uri}"
      } -> #{
        error.message
      }"

      throw error
