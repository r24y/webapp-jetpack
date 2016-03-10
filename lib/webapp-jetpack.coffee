WebappJetpackView = require './webapp-jetpack-view'
{CompositeDisposable} = require 'atom'

JETPACK_URI = 'webappjetpack://start'

module.exports = WebappJetpack =
  webappJetpackView: null
  subscriptions: null

  activate: (state) ->
    @webappJetpackView = new WebappJetpackView(state.webappJetpackViewState)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    atom.workspace.addOpener (uri) => @opener uri

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'webapp-jetpack:open': => @open()

    @webappJetpackView

  opener: (uri) ->
    return unless uri is JETPACK_URI
    @webappJetpackView

  open: -> atom.workspace.open JETPACK_URI

  deactivate: ->
    @subscriptions.dispose()
    @webappJetpackView.destroy()

  serialize: ->
    webappJetpackViewState: @webappJetpackView.serialize()
