{CompositeDisposable} = require 'atom'

#TocludeView = require './toclude-view'

Test = require './test'

module.exports = Toclude =
  subscriptions: null

  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace',
                                         'toclude:toggle': => @toggle()

  deactivate: ->
    @modalPanel.destroy()    @subscriptions.dispose()

  serialize: ->
    tocludeViewState: @tocludeView.serialize()

  toggle: ->
    console.log 'Toclude was toggled!'

    atom.notifications.addSuccess(Test.hello)

    Test.testfunc()
