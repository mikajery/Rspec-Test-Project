FactoryGirl.define "EmailTemplate", ->
  @sequence("id", "uid")
  
  @name = "Email template " + @uid
  @html = base64_encode_urlsafe("HTML body")
  @text = base64_encode_urlsafe("Text body")
