{$, TextEditorView, View} = require 'atom-space-pen-views'
spawn = require('child_process').spawn
exec = require('child_process').exec
fs = require 'fs-plus'
path = require 'path'

module.exports =
class AtomXsltransformView extends View

  @content: ->
    @div class: 'atom-xsltransform', =>
      @subview 'miniEditor', new TextEditorView(mini: true)
      @div class: 'error', outlet: 'error'
      @div class: 'message', outlet: 'message'

  initialize: ->
    @commandSubscription = atom.commands.add 'atom-workspace',
      'atom-xsltransform:transform-xml': => @attach()
    @miniEditor.on 'blur', => @close()
    atom.commands.add @element,
      'core:confirm': => @transform()
      'core:cancel': => @close()

  attach: ->
    @panel ?= atom.workspace.addModalPanel(item: this, visible: false)
    @previouslyFocusedElement = $(document.activeElement)

    if not @lastXslEntry
      editorPath = atom.workspace.getActiveTextEditor()?.getPath()
      @setPathText(path.dirname(editorPath))
    else
      @setPathText(@lastXslEntry)

    @panel.show()
    @message.text("Enter Stylesheet path")
    @miniEditor.focus()

  close: ->
    @miniEditor.setText('')
    @panel.hide()
    @previouslyFocusedElement?.focus()

  setPathText: (placeholderName, rangeToSelect) ->
    editor = @miniEditor.getModel()
    editor.setText(placeholderName)

  transform: ->
    xmlEditor = atom.workspace.getActiveTextEditor()
    xmlBuffer = xmlEditor.getBuffer()
    xmlFilename = xmlBuffer.file?.path
    xmlText = xmlEditor.getText()

    xslFilename = @miniEditor.getText()
    @lastXslEntry = xslFilename
    @lastEditor = xmlEditor
    @close()

    try
      if !(atom.config.get('atom-xsltransform.externalXslToolPath')?.match("^<.*>$"))
        @doExternalTransform xmlFilename, xslFilename
      else
        view = new TextEditorView()

        panes = atom.workspace.getPanes()
        pane = panes[panes.length - 1].splitRight(view)
        pane.activateItem(view.getModel())

        xslText = fs.readFileSync xslFilename
        xslResult = @doTransform xmlText, xslText.toString()
        view.setText(xslResult)

    catch err
      view.setText(err.stack)

  doTransform: (xml, xsl) ->
    httpRequest = new XMLHttpRequest()
    parser = new DOMParser()
    xsltProcessor = new XSLTProcessor()
    xmlSerializer = new XMLSerializer()

    xmlDoc = parser.parseFromString(xml, "text/xml")
    xslDoc = parser.parseFromString(xsl, "text/xml")

    xsltProcessor.importStylesheet xslDoc
    resultDocument = xsltProcessor.transformToDocument(xmlDoc)

    xmlSerializer.serializeToString(resultDocument);

  doExternalTransform: (xmlFilePath, xslFilePath) ->
    cmd = atom.config.get('atom-xsltransform.externalXslToolPath')

    cmd = cmd.replace("%XML", xmlFilePath)
    cmd = cmd.replace("%XSL", xslFilePath)


    child = exec( cmd,
          (error, stdout, stderr) ->
            view = new TextEditorView()
            panes = atom.workspace.getPanes()
            pane = panes[panes.length - 1].splitRight(view)
            pane.activateItem(view.getModel())

            if error
              view.setText(stderr);
            else if stderr
              view.setText(stderr);
            else
              view.setText(stdout);
    )
