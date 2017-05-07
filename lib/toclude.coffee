{CompositeDisposable} = require 'atom'

Block = require './block'
Util = require './util'

note = atom.notifications
deny = (err) -> throw {guard: true, message: err}

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

    dup = Util.duped(closers)
    if dup? then deny "Block closer /#{dup.name} must be unique."
    note.addInfo("no dups found")
