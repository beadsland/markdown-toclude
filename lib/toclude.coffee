{CompositeDisposable} = require 'atom'

Block = require './block'

module.exports = Toclude =
  subscriptions: null

  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace',
                                         'toclude:run': => @run()

  deactivate: ->
    @subscriptions.dispose()

  serialize: ->

  run: ->
    atom.notifications.addSuccess('toclude running')

    editor = atom.workspace.getActiveTextEditor()
    if (editor)
      text = editor.getBuffer().getText()
      Block.testfunc(text)
