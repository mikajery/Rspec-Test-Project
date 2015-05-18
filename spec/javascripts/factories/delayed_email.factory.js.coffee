FactoryGirl.define "DelayedEmail", ->
  @sequence("id", "uid")
  @subject = "Subject"
  @send_at = do ->
    from = new Date().getTime()
    duration = 1000 * 60 * 60 * 24 * 40 # 40 days
    new Date(from + Math.random() * duration).toJSON()

  @tos = ["david@turinginc.com"]

  @html_part = base64_encode_urlsafe("HTML body")
