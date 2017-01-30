#
# zero padding
#

module.exports =  (num, numDigits)->
  num = '' + num
  for i in [0...numDigits]
    num = '0' + num
  return num.slice -numDigits
