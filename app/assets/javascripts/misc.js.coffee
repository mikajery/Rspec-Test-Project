window.base64_decode_urlsafe = (data) ->
  return atob(data.replace(/-/g, '+').replace(/_/g, '/'))

window.base64_encode_urlsafe = (data) ->
  return btoa(data).replace(/\+/g, '-').replace(/\//g,'_')

window.escapeHTML = (data) ->
  return $("<div />").text(data).html()
