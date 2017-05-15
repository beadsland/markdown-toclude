{CompositeDisposable} = require 'atom'

Block = require './block'
GC = require './gc'
Util = require './util'

fs = require 'fs'
path = require 'path'

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
    tag = tag.toUpperCase()
    Block.insert_block_unless_found(editor, tag)

    text = editor.getText()
    closers = Block.find_block_closers(text)
    blocks = Block.find_blocks_from_closers(text, closers)
    block = (item for item in blocks when item.name is tag)[0]

    GC.push_trash(editor, block.content.slice, "#{content}")
    Util.replace_in_buffer(editor, \
                           block.content.start, block.content.end, \
                           "\n\n#{content}\n\n")

  do_run: ->
    return unless editor = atom.workspace.getActiveTextEditor()
    return unless editor.getGrammar().scopeName is "source.gfm"

    GC.push_trash(editor, "<!-- a -->\n<!-- b -->")

    content = new Date
    tag = 'BOO'
    @update_block(editor, tag, content)

    tocludes = Block.find_tocludes_comments(editor.getText())
    for t in tocludes
      note.addInfo("#{t.name} from #{t.params.target}")
      edpath = path.dirname(editor.getPath())
      file = "#{edpath}/#{t.params.target}"
      slurp = fs.readFileSync(file, 'utf8')
      re = RegExp("^[ \t]*[-+*][ \t].*$", 'mg')
      match = slurp.match(re)
      top = ""
      if match? then top = match.slice(0, 5).join("\n")
      note.addInfo(top)
      @update_block(editor, t.params.name, top)
