{CompositeDisposable} = require 'atom'

Block = require './block'
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
    text = editor.getBuffer().getText()

    closers = Block.find_block_closers(text)
    blocks = Block.find_blocks_from_closers(text, closers)
    nonblocks = Block.find_nonblocks_from_blocks(text, blocks)

    comments = Block.find_noncloser_comments(text)
    tocludes = (item for item in comments when item.name is "TOCLUDE")
    tocludes = for t in tocludes
      t.parastr = RegExp("<!-- TOCLUDE: ([^>]*?) -->").exec(t.comment)[1]
      t.params = []
      pattern = "(\\w+): (\\w+)"
      # is this if test even necessary??
      if true
      #if (RegExp(pattern).test(t.parastr))
        re = RegExp(pattern, 'g')
        while m = re.exec(t.parastr)
          t.params[m[1]] = m[2]
      t # next element in for list

    for t in tocludes
      note.addInfo("TOCLUDE params '#{t.parastr}'")
      for p of t.params
        note.addInfo("TOCLUDE params[#{p}] = #{t.params[p]}")
