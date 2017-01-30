#
# map
#

module.exports =  (value, inputMin, inputMax, outputMin, outputMax, clamp = true)->
  if clamp is true
    if value < inputMin then return outputMin
    if value > inputMax then return outputMax

  p = (outputMax - outputMin) / (inputMax - inputMin)
  return ((value - inputMin) * p) + outputMin
