Contents = require '../_common/Contents'

class Index extends Contents
  constructor: ->
    super 'index'


  start: ->
    tkmh.animateFromTtl()
    return

module.exports = Index
