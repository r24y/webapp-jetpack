React = require 'react'
$ = React.DOM
loader = require '../util/loader'
icon = require '../util/icon'
sh = require 'shelljs'
semver = require 'semver'
opener = require 'opener'

DESIRED_NODE_VERSION = '>=4.3.2'

module.exports =
class Node extends React.Component
  constructor: (props) ->
    super props
    this.state =
      nodeInstalled: null
      loading: no

  componentDidMount: -> @checkNodeVersion()

  checkNodeVersion: ->
    this.setState
      error: null
      nodeInstalled: null
      success: no
      loading: yes

    node = sh.which 'node'
    unless node
      return this.setState
        error: 'No "node" executable found on your system!'
        loading: no
    sh.exec "\"#{node}\" -v", silent: yes, (code, stdout, stderr) =>
      if code isnt 0
        this.setState
          error: stderr
          loading: no

      else
        this.setState
          nodeInstalled: stdout.trim()
          success: semver.satisfies stdout, DESIRED_NODE_VERSION
          loading: no

  onInstallBtnClick: => opener 'https://nodejs.org'
  onCheckAgainClick: => @checkNodeVersion()

  renderVersionMessage: ->
    $.p {}, [
      "Node version #{@state.nodeInstalled} detected, needed #{DESIRED_NODE_VERSION}."
    ]

  renderSuccessMessage: -> "Congrats, you have Node #{@state.nodeInstalled}!"

  renderErrorMessage: ->
    {error, nodeInstalled} = @state
    [
      if error?
        [
          $.p {}, "Error occurred while checking Node version. This usually means
            it's not installed."
          $.pre {}, error
        ]
      else
        @renderVersionMessage()
      $.p {}, [
        'Visit '
        $.a href: 'https://nodejs.org', 'nodejs.org'
        ' and install version '
        $.strong {}, '4.4.0 LTS'
        ". Make sure you install the following when prompted:"
        $.ul {}, [
          $.li {}, 'Node.js runtime'
          $.li {}, 'npm package manager'
          $.li {}, 'Add to PATH'
        ]
      ]
      $.div className: 'btn-group', [
        $.button
          className: 'btn btn-primary'
          onClick: @onInstallBtnClick
        , [
          'Install Node.js'
        ]
        $.button
          className: 'btn'
          onClick: @onCheckAgainClick
        , [
          'Check again'
        ]
      ]
    ]


  render: ->
    {nodeInstalled, success, loading} = @state
    {seq} = @props
    headerProps =
      className: "panel-heading #{
        if nodeInstalled is null
          'header'
        else unless success
          'header-error'
        else
          'header-success'
        }"

    if success
      body = @renderSuccessMessage()
    else
      body = @renderErrorMessage()

    $.div className: 'inset-panel', [
      $.h2 headerProps, [
        "#{seq}. Install Node.js "
        if loading
          loader 'small'
        else if success
          icon 'check'
        else if nodeInstalled
          icon 'alert'
        else
          ''
      ]
      $.div className: 'panel-body padded', body
    ]
