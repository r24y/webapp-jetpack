React = require 'react'
$ = React.DOM
ReactDom = require 'react-dom'

Tasks = require './tasks'

module.exports =
class WebappJetpackView
  constructor: (serializedState) ->
    # Create root element
    @element = document.createElement('div')
    @element.classList.add('webapp-jetpack')

    ReactDom.render @render(), @element

  getTitle: -> 'Webapp Jetpack'

  render: -> React.createElement Tasks

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @element.remove()

  getElement: ->
    @element
