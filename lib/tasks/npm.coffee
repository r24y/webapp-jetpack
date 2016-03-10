React = require 'react'
$ = React.DOM
loader = require '../util/loader'
icon = require '../util/icon'
sh = require 'shelljs'
semver = require 'semver'
opener = require 'opener'

DESIRED_NPM_VERSION = '>=3.0.0'

module.exports =
class NPM extends React.Component
  constructor: (props) ->
    super props
    this.state =
      npmInstalled: null
      loading: no

  componentDidMount: -> @checkNodeVersion()

  checkNodeVersion: ->
    this.setState
      error: null
      npmInstalled: null
      success: no
      loading: yes

    node = sh.which 'npm'
    console.info node
    unless node
      return this.setState
        error: 'No "npm" executable found on your system!'
        loading: no
    sh.exec "#{node} -v", silent: yes, (code, stdout, stderr) =>
      if code isnt 0
        this.setState
          error: stderr
          loading: no

      else
        console.log stdout, DESIRED_NPM_VERSION, semver.satisfies stdout, DESIRED_NPM_VERSION
        this.setState
          npmInstalled: stdout
          success: semver.satisfies stdout, DESIRED_NPM_VERSION
          loading: no

  onInstallBtnClick: => opener 'https://nodejs.org'

  renderVersionMessage: ->
    {npmInstalled} = @state
    $.p {}, [
      "NPM version #{npmInstalled} detected, needed #{DESIRED_NPM_VERSION}."
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
      $.p {}, [
        'Visit '
        $.a href: 'https://nodejs.org', 'nodejs.org'
        ' and install version '
        $.strong {}, '4.4.0 LTS'
        '.'
      ]
      $.button
        className: 'btn'
        onClick: @onInstallBtnClick
      , [
        'Install Node.js'
      ]
    ]


  render: ->
    {npmInstalled, success, loading} = @state
    headerProps =
      className: "panel-heading #{
        if npmInstalled is null
          'header'
        else unless success
          'header-error'
        else
          'header-success'
        }"

    body = if success
      @renderSuccessMessage()
    else
      @renderErrorMessage()

    $.div className: 'inset-panel', [
      $.h2 headerProps, [
        'Install NPM '
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
