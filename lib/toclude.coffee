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
    if dup? then deny "Block close comment /#{dup.name} must be unique."
    note.addInfo("no dups found")

    for close in closers
      note.addInfo(close.name)
      openers = Block.find_block_openers(text.slice(0, close.start-1))
      openers = (item for item in openers when item.name is close.name)
      if (not openers.length)
        openers = Block.find_block_openers(text.slice(close.end+1))
        openers = (item for item in openers when item.name is close.name)
        if (openers.length)
          deny "Block open comment #{close.name} must not trail \
                close comment /#{close.name}."
        else
          deny "Block /#{close.name} must have a matching block open comment."
      else
        if (openers.length > 1)
          deny "Block open comment #{dup.name} must be unique."
        else
          openers = Block.find_block_openers(text.slice(close.end+1))
          openers = (item for item in openers when item.name is close.name)
          if (openers.length)
            deny "Block open comment #{close.name} must not trail \
                  close comment /#{close.name}."
