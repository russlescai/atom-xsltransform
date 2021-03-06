{$, TextEditorView, View} = require 'atom-space-pen-views'
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
      if (atom.config.get('atom-xsltransform.externalXslToolPath')?.length == 0)
        view = new TextEditorView()

        activePane = atom.workspace.getActivePane();
        pane = activePane.splitRight(view);
        pane.activateItem(view.getModel())

        xslText = fs.readFileSync xslFilename
        xslResult = @doTransform xmlText, xslText.toString()
        view.setText(xslResult)
      else
        @doExternalTransform xmlFilename, xslFilename

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

    cmd = cmd.replace("%XML", "\"" + xmlFilePath + "\"")
    cmd = cmd.replace("%XSL", "\"" + xslFilePath + "\"")

    exec = require('child_process').exec
    child = exec( cmd,
          (error, stdout, stderr) ->
            view = new TextEditorView()
            activePane = atom.workspace.getActivePane();
            pane = activePane.splitRight(view);
            pane.activateItem(view.getModel())

            text = ""

            if error
              text = "#{stderr}\n\n"
            else
              text = "#{stdout}\n\n"

            view.setText(text)
    )
