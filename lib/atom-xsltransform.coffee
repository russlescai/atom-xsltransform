AtomXsltransformView = require './atom-xsltransform-view'

module.exports = AtomXsltransform =
  view: null

  activate: (state) ->
    @view = new AtomXsltransformView()

  deactivate: ->
    @view?.destroy()
