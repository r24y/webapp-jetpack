React = require 'react'
$ = React.DOM
loader = require '../util/loader'
icon = require '../util/icon'
sh = require 'shelljs'
semver = require 'semver'
opener = require 'opener'

DESIRED_NPM_VERSION = '>=3.0.0'

module.exports =
class Npm extends React.Component
  constructor: (props) ->
    super props
    this.state =
      npmInstalled: null
      loading: no

  componentDidMount: -> @checkNpmVersion()

  checkNpmVersion: ->
    this.setState
      error: null
      npmInstalled: null
      success: no
      loading: yes

    npm = sh.which 'npm'
    unless npm
      return this.setState
        error: 'No "npm" executable found on your system!'
        loading: no
    sh.exec "\"#{npm}\" -v", silent: yes, (code, stdout, stderr) =>
      if code isnt 0
        this.setState
          error: stderr
          loading: no

      else
        this.setState
          npmInstalled: stdout
          success: semver.satisfies stdout, DESIRED_NPM_VERSION
          loading: no

  onCheckAgainClick: => @checkNpmVersion()
  onUpdateNpmClick: =>
    @setState
      loading: yes

    npm = sh.which 'npm'
    unless npm
      return this.setState
        error: 'No "npm" executable found on your system!'
        loading: no
    sh.exec "\"#{npm}\" install --global \"npm@>=3.6.0\"", silent: true, (code, stdout, stderr) =>
      console.info stdout
      if code isnt 0
        console.error stderr
      @checkNpmVersion()

  renderVersionMessage: ->
    {npmInstalled} = @state
    $.p {}, [
      "npm version #{npmInstalled} detected, needed #{DESIRED_NPM_VERSION}."
    ]

  renderSuccessMessage: -> [
    @renderVersionMessage()
  ]

  renderErrorMessage: ->
    {error, npmInstalled} = @state
    [
      if error?
        $.pre {}, error
      else
        @renderVersionMessage()
      $.div className: 'btn-group', [
        $.button
          className: 'btn btn-primary'
          onClick: @onUpdateNpmClick
        , [
          'Update npm'
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
    {npmInstalled, success, loading} = @state
    {seq} = @props
    headerProps =
      className: "panel-heading #{
        if npmInstalled is null
          'header'
        else unless success
          'header-error'
        else
          'header-success'
        }"

    body = [
      $.p {}, [
        "npm is a package manager for Node modules. If you can dream up a piece
          of JavaScript that you need, it's probably on "
        $.a href: 'http://npmjs.com', 'npmjs.com'
        ". npm helps you by downloading it when you need it, with very little
          effort on your part."
      ]
      $.p {}, [
        "\"npm\" is not a typo! It's supposed to be lowercase. "
        $.a href: 'https://twitter.com/othiym23/status/707771645746749440', '(Confirmed on Twitter.)'
      ]
      unless npmInstalled
        $.p {}, "npm is capable of updating itself, but first you need to
          complete step #{seq - 1} so that it has permission to update its own
          files."
      else if success
        @renderSuccessMessage()
      else
        @renderErrorMessage()
    ]

    $.div className: 'inset-panel', [
      $.h2 headerProps, [
        "#{seq}. Update to npm 3.0 "
        if loading
          loader 'small'
        else if success
          icon 'check'
        else if npmInstalled
          icon 'alert'
        else
          ''
      ]
      $.div className: 'panel-body padded', body
    ]
