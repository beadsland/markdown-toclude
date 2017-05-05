TocludeView = require './toclude-view'
{CompositeDisposable} = require 'atom'

module.exports = Toclude =
  tocludeView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @tocludeView = new TocludeView(state.tocludeViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @tocludeView.getElement(),
                                               visible: false)

    # Events subscribed to in atom's system can be easily cleaned up
    # with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace',
                                         'toclude:toggle': => @toggle()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @tocludeView.destroy()

  serialize: ->
    tocludeViewState: @tocludeView.serialize()

  toggle: ->
    console.log 'Toclude was toggled!'

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      editor = atom.workspace.getActiveTextEditor()
      words = editor.getText().split(/\s+/).length
      @tocludeView.setCount(words)
      @modalPanel.show()

#    if @modalPanel.isVisible()
#      @modalPanel.hide()
#    else
#      @modalPanel.show()
