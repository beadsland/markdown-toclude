{CompositeDisposable} = require 'atom'

Block = require './block'
GC = require './gc'
Util = require './util'
deny = Util.deny

note = atom.notifications

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
    note.addSuccess('toclude running')
    try @do_run() catch error
      if error.guard? then note.addError("#{error.message}")
      else note.addFatalError(error.stack)

  do_run: ->
    return unless editor = atom.workspace.getActiveTextEditor()
    return unless editor.getGrammar().scopeName is "source.gfm"

    tag = 'BOO'
    Block.insert_block_unless_found(editor.getBuffer(), tag)

    text = editor.getText()
    closers = Block.find_block_closers(text)
    blocks = Block.find_blocks_from_closers(text, closers)
    boo = (item for item in blocks when item.name is tag)[0]
    note.addInfo(boo.content.slice)

    today = new Date

#    text = GC.push_trash(text, today.toTimeString(), "yes\nmaybe")

    marker = editor.markBufferPosition(editor.getCursorBufferPosition())
    marker.invalidate = 'never'
    editor.setText(text)
    editor.setCursorBufferPosition(marker.getBufferRange().start)
