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
      result = Block.find_block_closers(text)
      if (result?)
        note.addInfo "found #{b.block} from #{b.start} to #{b.end}" \
                                                  for b in result
