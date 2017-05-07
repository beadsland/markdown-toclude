{CompositeDisposable} = require 'atom'
note = atom.notifications

Block = require './block'
Util = require './util'

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
    try @do_run() catch error then note.addError("#{error}")

  do_run: ->
    return unless editor = atom.workspace.getActiveTextEditor()
    text = editor.getBuffer().getText()
    
    closers = Block.find_block_closers(text)
    if Util.duped(closers)
      throw Error("Block closer /#{dup.name} must be unique.")
    note.addInfo("no dups found")
