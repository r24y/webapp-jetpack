React = require 'react'
$ = React.DOM
loader = require '../util/loader'
icon = require '../util/icon'
sh = require 'shelljs'
semver = require 'semver'
opener = require 'opener'
fs = require 'fs'
path = require 'path'
os = require 'os'

module.exports =
class NpmPrefix extends React.Component
  constructor: (props) ->
    super props
    @state =
      prefix: null
      checking: no
      doneChecking: no
      passed: no
      homeDir: null

  componentDidMount: ->
    @fetchNpmPrefix()
    @fetchHomeDir()

  fetchHomeDir: ->
    @setState
      homeDir: os.homedir()

  fetchNpmPrefix: ->
    @setState
      error: null
      prefix: null
      success: no
      checking: yes
      doneChecking: no
      passed: no

    npm = sh.which 'npm'
    unless npm
      return @setState
        error: 'No "npm" executable found on your system!'
        loading: no
    sh.exec "\"#{npm}\" config get prefix", silent: yes, (code, stdout, stderr) =>
      if code isnt 0
        @setState
          error: stderr
          checking: no
          doneChecking: yes
          passed: no

      else
        prefix = stdout.trim()
        @checkNpmPrefix prefix
        @setState
          prefix: prefix
          checking: yes
          doneChecking: no
          passed: no

  checkNpmPrefix: (prefix) ->
    touchfile = path.join prefix, 'poke'
    fs.writeFile touchfile, ' ', (err) =>
      if err
        console.error err
        return @setState
          error: "You don't have write access to the #{prefix} directory.
            You'll need to choose a new directory so you can install your
            own packages."
          checking: no
          doneChecking: yes
          passed: no
      fs.unlink touchfile, (err) =>
        return @setState
          checking: no
          doneChecking: yes
          passed: yes

  onCheckAgainClick: => @fetchNpmPrefix()

  renderSuccessMessage: -> $.p {}, "You are now able to install programs and
    packages from npm to your system."

  renderErrorMessage: ->
    {error, npmInstalled, homeDir} = @state
    [
      $.p {}, (error ? 'Error')
      $.div className: 'btn-group', [
        $.button
          className: 'btn btn-primary'
          onClick: @fixPrefix
          disabled: not homeDir
        , [
          'Automatically set prefix'
        ]
        $.button
          className: 'btn'
          onClick: @onCheckAgainClick
        , [
          'Check again'
        ]
      ]
    ]

  fixPrefix: ->
    {homeDir} = @state
    @setState
      checking: yes
      doneChecking: no

    prefix = path.join homeDir, '.local', 'npm'

    sh.exec "\"#{npm}\" config set prefix \"#{prefix}\"", silent: yes, (code, stdout, stderr) =>
      if code isnt 0
        return @setState
          error: stderr
          checking: no
          doneChecking: yes


  render: ->
    {checking, doneChecking, passed, prefix} = @state
    {seq} = @props
    headerProps =
      className: "panel-heading #{
        if prefix is null
          'header'
        else unless passed
          'header-error'
        else
          'header-success'
        }"

    body = [
      $.p {}, [
        "This section makes sure you can install things you want from npm. "
        "If you're interested, this "
        $.a href: 'https://docs.npmjs.com/getting-started/fixing-npm-permissions', 'fixes npm permissions'
        " by making sure you have write access to the install directory."
      ]
      unless prefix
        "Checking..."
      else if passed
        @renderSuccessMessage()
      else
        @renderErrorMessage()
    ]

    $.div className: 'inset-panel', [
      $.h2 headerProps, [
        "#{seq}. Set up location for npm to install packages "
        if checking
          loader 'small'
        else if passed
          icon 'check'
        else if prefix
          icon 'alert'
        else
          ''
      ]
      $.div className: 'panel-body padded', body
    ]
