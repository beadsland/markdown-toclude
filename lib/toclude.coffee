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

    text = editor.getBuffer().getText()

    closers = Block.find_block_closers(text)
    nonclosers = Block.find_noncloser_comments(text)
    blocks = Block.find_blocks_from_closers(text, closers)
    nonblocks = Block.find_nonblocks_from_blocks(text, blocks)
    tocludes = Block.find_tocludes_comments(text)
    first = Block.find_first_bullet_from_nonblocks(text, nonblocks)

#    paramstr = Block.find_parameter_comments(text)
#    for n in paramstr
#      note.addInfo("paramstr #{n.name} #{n.start} to #{n.end}")

    if first then note.addInfo("first '#{first.line}' at #{first.start}")

    tag = 'BOO'
    text = Block.insert_block_unless_found(text, tag)


    trash = GC.find_trash_comment(text)
    unless trash then text = GC.append_trash_comment(text, "")
    trash = GC.find_trash_comment(text)

    content = GC.compact_trash(trash.content, "yes\nmaybe")
    text = GC.clear_trash_comment(text)
    text = GC.append_trash_comment(text, content)

    editor.getBuffer().setText(text)
