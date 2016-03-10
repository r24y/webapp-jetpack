React = require 'react'
$ = React.DOM

SECTION_NAMES = [
  'node'
  'npm'
  'npm-prefix'
]
sections = SECTION_NAMES.map (name) -> require "./#{name}"

module.exports =
class Tasks extends React.Component
  next: -> (i) =>
  render: ->
    $.div className: 'Tasks', [
      $.h1 className: 'main-header', 'Webapp Jetpack'
      $.p {}, 'Jetpack will get you started quickly with Node.js-based development.'
      sections.map (Section, i) => React.createElement Section,
        seq: i + 1
        onPass: @next(i + 1)
    ]
