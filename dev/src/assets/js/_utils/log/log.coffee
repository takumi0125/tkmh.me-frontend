#
# console.log wrapper
#

window.log = (->
  if window.console?
    if window.console.log.bind?
      return window.console.log.bind window.console
    else
      return window.console.log
  else
    return window.alert
)()
