React = require 'react'
$ = React.DOM

SECTION_NAMES = [
  'node'
  'npm'
]
sections = SECTION_NAMES.map (name) -> require "./#{name}"

module.exports =
class Tasks extends React.Component
  render: ->
    $.div {}, [
      $.h1 className: 'main-header', 'Webapp Jetpack'
      $.p {}, 'Jetpack will get you started quickly with Node.js-based development.'
      sections.map (Section) -> React.createElement Section
    ]
