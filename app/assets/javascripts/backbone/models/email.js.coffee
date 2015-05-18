class TuringEmailApp.Models.Email extends Backbone.Model
  idAttribute: "uid"

  defaults: ->
    "bounce_back_type": "never"
    "bounce_back_time": ""
    "tos": ""
    "ccs": ""
    "bccs": ""

  validation:
    uid:
      required: true

    message_id:
      required: true

    date:
      required: true
      isDate: true

    from_name:
      required: true

    from_address:
      required: true
      pattern: "email"

    sender_name: {}

    sender_address:
      pattern: "email"

    reply_to_name: {}

    reply_to_address:
      required: true
      pattern: "email"

    tos:
      required: true
      pattern: "email"

    ccs:
      pattern: "email"

    bccs:
      pattern: "email"

    subject:
      required: true

    html_part: {}

    text_part: {}

    body_text: {}

    email_attachments:
      isArray: true

    email_attachment_uploads:
      isArray: true

    folder_ids:
      isArray: true

  # TODO write tests
  @parseHeaders: (emailParsed, headers) ->
    headersMap =
      "message-id": "message_id"
      "list-id": "list_id"
      "date": "date"
      "subject": "subject"
      "to": "tos"
      "cc": "ccs"
      "bcc": "bccs"

    emailHeadersMap =
      "from": "from_"
      "sender": "sender_"
      "reply_to": "reply_to_"

    for header in headers
      found = false

      headerName = header.name.toLowerCase()
      parsedKey = headersMap[headerName]
      if parsedKey?
        if headerName is "date"
          emailParsed[parsedKey] = new Date(header.value)
        else
          emailParsed[parsedKey] = header.value

        found = true

      if not found
        parsedPrefix = emailHeadersMap[headerName]
        if parsedPrefix?
          parsedEmail = EmailAddressParser.parseOneAddress(header.value)
          if parsedEmail?
            emailParsed[parsedPrefix + "name"] = parsedEmail.name
            emailParsed[parsedPrefix + "address"] = parsedEmail.address

  # TODO write tests
  @parseBody: (emailParsed, parts) ->
    return if not parts?

    foundText = false
    foundHTML = false

    for part in parts
      if not foundText and part.mimeType.toLowerCase() == "text/plain" and
         part.body.size > 0 and not part.body.attachmentId? and part.body.data?
        emailParsed.text_part_encoded = part.body.data
        emailParsed.text_part = base64_decode_urlsafe(emailParsed.text_part_encoded)
        foundText = true

      if not foundHTML and part.mimeType.toLowerCase() == "text/html" and
         part.body.size > 0 and not part.body.attachmentId? and part.body.data?
        emailParsed.html_part_encoded = part.body.data
        emailParsed.html_part = base64_decode_urlsafe(emailParsed.html_part_encoded)
        foundHTML = true

      if not emailParsed.text_part_encoded? or not emailParsed.html_part_encoded?
        @parseBody(emailParsed, part.parts)

  @localDateString: (emailDateString) ->
    if emailDateString?
      now = new Date()
      emailDate = new Date(emailDateString)

      if emailDate > new Date().setHours(now.getHours() - 18)
        return emailDate.toLocaleTimeString(navigator.language, {hour: "2-digit", minute: "2-digit"})
      else if emailDate > new Date().setMonth(now.getMonth() - 6)
        return emailDate.toLocaleDateString(navigator.language, {month: "short", day: "numeric"})
      else
        return emailDate.toLocaleDateString(navigator.language)
    else
      return ""

  sendEmail: ->
    $.post("/api/v1/email_accounts/send_email", @toJSON(), undefined, "json")

  sendLater: (sendAtDateTime) ->
    data = @toJSON()
    data["sendAtDateTime"] = sendAtDateTime

    $.post("/api/v1/email_accounts/send_email_delayed", data, undefined, "json")

  localDateString: ->
    TuringEmailApp.Models.Email.localDateString(@get("date"))
