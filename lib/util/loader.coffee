$ = (require 'react').DOM

module.exports = (size) ->
  $.span className: "loading loading-spinner-#{size} inline-block"
