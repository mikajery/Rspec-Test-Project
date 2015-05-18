FactoryGirl.define "EmailSignature", ->
  @sequence("id", "uid")

  @name = "Email template " + @uid
  @html = base64_encode_urlsafe("HTML body")
  @text = base64_encode_urlsafe("Text body")

  @created_at = "2015-01-11T20:00:46.893Z"