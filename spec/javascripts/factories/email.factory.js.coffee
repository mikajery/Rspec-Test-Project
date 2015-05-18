FactoryGirl.define "Email", ->
  @auto_filed = false
  @sequence("id", "uid")
  @draft_id = null
  
  @sequence("id", "message_id")
  @message_id = "message_" + @message_id
  
  @sequence("id", "list_id")
  @list_id = "message_" + @list_id

  @seen = false
  @snippet = "snippet"
  @date = new Date()

  @from_name = "Allan"
  @from_address = "allan@turing.com"

  @sender_name = "Sender"
  @sender_address = "sender@turing.com"

  @reply_to_name = "Allan"
  @reply_to_address = "reply@turing.com"

  @tos = "david@turinginc.com"
  @ccs = "stewart@turinginc.com"
  @bccs = "bcc@turinginc.com"
  
  @subject = "Subject"
  @html_part_encoded = base64_encode_urlsafe("HTML body")
  @text_part_encoded = base64_encode_urlsafe("Text body")
  @body_text = null

  @folder_ids = ["Test"]
  
  @email_attachments = _.map(FactoryGirl.createLists("EmailAttachment", FactoryGirl.SMALL_LIST_SIZE),
    (emailAttachment) -> emailAttachment.toJSON()
  )
