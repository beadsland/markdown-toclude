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
    note = atom.notifications
    note.addSuccess('toclude running')

    editor = atom.workspace.getActiveTextEditor()
    if (editor)
      text = editor.getBuffer().getText()
      closers = Block.find_block_closers(text)
      note.addInfo("#{closers.length}")
      if closers?
        saw = []
        for b in closers
          note.addInfo("looking at #{b.name}")
          if saw[b.name] is true
            note.addError("Block closer /#{b.name} must be unique.")
          else saw[b.name] = true
