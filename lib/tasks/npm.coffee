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

  componentDidMount: -> @checkNpmVersion()

  checkNpmVersion: ->
    this.setState
      error: null
      npmInstalled: null
      success: no
      loading: yes

    npm = sh.which 'npm'
    console.info npm
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
        console.log stdout, DESIRED_NPM_VERSION, semver.satisfies stdout, DESIRED_NPM_VERSION
        this.setState
          npmInstalled: stdout
          success: semver.satisfies stdout, DESIRED_NPM_VERSION
          loading: no

  onInstallBtnClick: => @checkNpmVersion()

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
      $.p {}, [
        'This should take care of itself if you install Node as above.'
      ]
      $.button
        className: 'btn'
        onClick: @onInstallBtnClick
      , [
        'Check again'
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
        'Install npm '
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
