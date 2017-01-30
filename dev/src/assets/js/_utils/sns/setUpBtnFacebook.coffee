#
# setUpBtnFacebook
# require jquery
#

module.exports = ($btn, shareURL, description = '')->
  url = 'https://www.facebook.com/sharer/sharer.php?&display=popup&u='
  url += "#{encodeURIComponent(shareURL)}"

  if description
    url += "&description=#{encodeURIComponent(description)}"

  $btn.on 'click', (e)->
    window.open url, "facebookShare#{new Date().getTime()}", 'width=670,height=400'
    return false
