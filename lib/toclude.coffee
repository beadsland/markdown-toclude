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

  update_block: (editor, tag, content) ->
    Block.insert_block_unless_found(editor, tag)

    text = editor.getText()
    closers = Block.find_block_closers(text)
    blocks = Block.find_blocks_from_closers(text, closers)
    block = (item for item in blocks when item.name is tag)[0]

    GC.push_trash(editor, block.content.slice, "#{content}")
    Util.replace_in_buffer(editor, \
                           block.content.start, block.content.end, \
                           "\n#{content}\n")

  do_run: ->
    return unless editor = atom.workspace.getActiveTextEditor()
    return unless editor.getGrammar().scopeName is "source.gfm"

    content = new Date
    tag = 'BOO'
    @update_block(editor, tag, content)
