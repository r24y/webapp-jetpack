$ = require('react').DOM
ReactDom = require 'react-dom'

console.log
  react: require 'react'
  'coffee-react-dom': require 'coffee-react-dom'
  'react-dom': require 'react-dom'



module.exports =
class WebappJetpackView
  constructor: (serializedState) ->
    # Create root element
    @element = document.createElement('div')
    @element.classList.add('webapp-jetpack')

    # Create message element
    message = document.createElement('div')
    message.textContent = "The WebappJetpack package is Alive! It's ALIVE!"
    message.classList.add('message')
    @element.appendChild(message)

    # Create React-handled element
    container = document.createElement('div')
    @element.appendChild(container)

    console.log @

    ReactDom.render @render(), container

  getTitle: -> 'Webapp Jetpack'

  render: ->
    $.div class: 'hello-world',
      $.h2 class: 'react-heading', 'Hello React in Atom!'
      $.p 'More content'

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @element.remove()

  getElement: ->
    @element
