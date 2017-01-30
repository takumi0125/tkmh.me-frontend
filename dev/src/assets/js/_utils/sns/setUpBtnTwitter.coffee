#
# setUpBtnTwitter
# require jquery
#

module.exports = ($btn, text, shareURL = '')->
  url = 'https://twitter.com/intent/tweet?'

  if shareURL is ''
    url += "text=#{encodeURIComponent(text)}"
  else
    url +="url=#{encodeURIComponent(shareURL)}&text=#{encodeURIComponent(text)}"

  $btn.on 'click', (e)->
    window.open url, 'twitterShare', 'width=670,height=400'
    return false
