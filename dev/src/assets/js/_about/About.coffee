Contents = require '../_common/Contents'

class About extends Contents
  constructor: ->
    super 'about'


  start: ->
    tkmh.animateToTtl 'about'
    return

module.exports = About
