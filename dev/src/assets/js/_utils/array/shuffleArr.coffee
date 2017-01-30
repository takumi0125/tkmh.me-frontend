#
# shuffle array
#

module.exports = (arr)->
  ret = []
  l = n = arr.length

  while n
    i = Math.floor(Math.random() * l)

    if i in arr
      ret.push arr[i]
      delete arr[i]
      n--

  return ret
