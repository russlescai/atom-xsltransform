AtomXsltransformView = require './atom-xsltransform-view'

module.exports = AtomXsltransform =

  config:
    externalXslToolPath:
      type: 'string'
      default: ''
      description: 'The path to an external Xsl tool. Use %XSL and %XML for file parameters'

  view: null

  activate: (state) ->
    @view = new AtomXsltransformView()

  deactivate: ->
    @view?.destroy()
