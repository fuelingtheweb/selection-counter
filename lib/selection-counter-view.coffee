class SelectionCounterView extends HTMLDivElement
  initialize: (@statusBar) ->
    @classList.add('selection-counter', 'inline-block')
    @handleEvents()

  attach: ->
    @tile = @statusBar.addLeftTile(item: this)

  handleEvents: ->
    @activeItemSubscription = atom.workspace.onDidChangeActivePaneItem =>
      @subscribeToActiveTextEditor()

    @subscribeToActiveTextEditor()

  getActiveTextEditor: ->
    atom.workspace.getActiveTextEditor()

  subscribeToActiveTextEditor: ->
    editor = @getActiveTextEditor()

    @positionSubscription?.dispose()
    @positionSubscription = editor?.onDidChangeCursorPosition =>
      @updateSelectionText()

    @selectionAddSubscription?.dispose()
    @selectionAddSubscription = editor?.onDidAddSelection =>
      @updateSelectionText()

    @selectionRemoveSubscription?.dispose()
    @selectionRemoveSubscription = editor?.onDidRemoveSelection =>
      @updateSelectionText()

    @updateSelectionText()

  buildStatusString: (selections, cursors) ->
    pattern = atom.config.get 'selection-counter.statusString'
    hide = atom.config.get 'selection-counter.hideWhenEmpty'
    if selections == 0 and cursors == 1 and hide == true
      return ''
    else
      pattern.replace('%s', selections.toString())
        .replace('%c', cursors.toString())

  updateSelectionText: ->
    editor = @getActiveTextEditor()
    if(editor?)
      selections = editor.getSelectedBufferRanges()
      cursors = editor.getCursorBufferPositions()

      numSelections = 0
      i = 0
      while i < selections.length
        if !selections[i].isEmpty()
          numSelections++
        i++

      statusString = @buildStatusString(numSelections, cursors.length - numSelections)
      if statusString == ''
        @style.display = 'none'
      else
        @style.display = 'inline-block'
        @textContent = statusString
    else
      @style.display = 'none'

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @positionSubscription?.dispose()
    @selectionAddSubscription?.dispose()
    @selectionRemoveSubscription?.dispose()
    @tile?.destroy()

module.exports = document.registerElement('selection-counter-status', prototype: SelectionCounterView.prototype)
