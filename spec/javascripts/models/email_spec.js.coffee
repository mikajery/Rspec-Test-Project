describe "Email", ->
  describe "Class Methods", ->
    describe "#localDateString", ->
      describe "when the date is within the last 18 hours", ->
        it "produces the a time format response", ->
          date = new Date(Date.now())
          isoDateString = date.toISOString()
          expectedResult = date.toLocaleTimeString(navigator.language, {hour: "2-digit", minute: "2-digit"})
          expect(TuringEmailApp.Models.Email.localDateString(isoDateString)).toEqual(expectedResult)

      describe "when the date is further back than 18 hours ago", ->
        it "produces a date format response", ->
          expect(TuringEmailApp.Models.Email.localDateString("2014-08-22T17:28:16.000Z")).toEqual "08/22/2014"

      describe "when the emailDateString is not defined", ->
        it "return an empty string", ->
          expect(TuringEmailApp.Models.Email.localDateString(null)).toEqual ""

    describe "#parseBody", ->
      describe "when the parts is not given", ->
        it "returns the undefined", ->
          expect(TuringEmailApp.Models.Email.parseBody(1, undefined)).toBeUndefined

      describe "when the parts is given", ->
        beforeEach ->
          @emailParsed = 
            text_part_encoded: ""
            text_part: ""

          @original_body_data = "body data"
          @encoded_body_data = base64_encode_urlsafe(@original_body_data)

          @part = 
            parts: ""
            mimeType: ""
            body:
              size: 2
              data: @encoded_body_data
        describe "when the Text is not found and the mimeType is 'text/plain' and the body is given and the attachmentId of the body is not given and the data of the body is given", ->
          beforeEach ->
            @part.mimeType = 'text/plain'

          it "saves the data of the body to the text_part_encoded of the emailParsed", ->
            
            TuringEmailApp.Models.Email.parseBody(@emailParsed, [@part])
            
            expect(@emailParsed.text_part_encoded).toEqual @encoded_body_data

          it "saves the decoded text_part_encoded of the emailParsed to the text_part of the emailParsed", ->
            TuringEmailApp.Models.Email.parseBody(@emailParsed, [@part])
            
            expect(@emailParsed.text_part).toEqual @original_body_data

        describe "when the HTML is not found and the mimeType is 'text/html' and the body is given and the attachmentId of the body is not given and the data of the body is given", ->
          beforeEach ->
            @part.mimeType = 'text/html'

          it "saves the data of the body to the html_part_encoded of the emailParsed", ->
            
            TuringEmailApp.Models.Email.parseBody(@emailParsed, [@part])
            
            expect(@emailParsed.html_part_encoded).toEqual @encoded_body_data

          it "saves the decoded text_part_encoded of the emailParsed to the html_part of the emailParsed", ->
            TuringEmailApp.Models.Email.parseBody(@emailParsed, [@part])
            
            expect(@emailParsed.html_part).toEqual @original_body_data

        describe "when above the both conditions are not met", ->

          it "calls the parseBody class methods", ->
            expect(TuringEmailApp.Models.Email.parseBody).toHaveBeenCalled
          
    describe "#parseHeaders", ->
      beforeEach ->
        @emailParsed = new Object
        @date_value = Date.parse("March 21, 2012");

      describe "when the proper header is given", ->
        describe "when the date of the header is given", ->
          beforeEach ->
            @header =
              name: "date"
              value: @date_value

          it "updates the date of the parsed email to the date format of the value", ->
            expected = new Date(@header.value)

            TuringEmailApp.Models.Email.parseHeaders(@emailParsed, [@header])

            expect( @emailParsed["date"] ).toEqual expected

        describe "when the date of the header is not given", ->
          beforeEach ->
            headerNames = ["message-id", "list-id", "subject", "to", "cc", "bcc"]
            
            @headerName = headerNames[Math.floor(Math.random() * 5)]

            @headersMap =
              "message-id": "message_id"
              "list-id": "list_id"
              "date": "date"
              "subject": "subject"
              "to": "tos"
              "cc": "ccs"
              "bcc": "bccs"

            @header =
              name: @headerName
              value: @date_value

          it "updates the field to the value", ->
            TuringEmailApp.Models.Email.parseHeaders(@emailParsed, [@header])

            expect( @emailParsed[@headersMap[@headerName]] ).toEqual @date_value

      describe "when the proper header is not given", ->
        describe "when the header matches either from or sender or reply_to", ->
          beforeEach ->
            headerNames = ["from", "sender", "reply_to"]
            @headerName = headerNames[Math.floor(Math.random() * 2)]
            @name = "Test Engineer"
            @email = "support@email.com"
            @emailHeadersMap =
              "from": "from_"
              "sender": "sender_"
              "reply_to": "reply_to_"
            @header =
              name: @headerName
              value: @name + "<" + @email + ">"

          describe "when could parse the address", ->
            beforeEach ->
              TuringEmailApp.Models.Email.parseHeaders(@emailParsed, [@header])

            it "updates the 'given header + name' field to the name of the value", ->            
              key = @emailHeadersMap[@headerName] + "name"
              expect( @emailParsed[key] ).toEqual @name
              
            it "updates the 'given header + address' field to the address of the value", ->
              key = @emailHeadersMap[@headerName] + "address"
              expect( @emailParsed[key] ).toEqual @email

          describe "when could not parse the address", ->
            beforeEach ->
              @stub = sinon.stub(EmailAddressParser, 'parseOneAddress').returns(undefined)
              TuringEmailApp.Models.Email.parseHeaders(@emailParsed, [@header])

            afterEach ->
              @stub.restore()
              
            it "does not update the 'given header + name' field to the name of the value", ->            
              key = @emailHeadersMap[@headerName] + "name"
              expect( @emailParsed[key] ).not.toEqual @name
              
            it "does not update the 'given header + address' field to the address of the value", ->
              key = @emailHeadersMap[@headerName] + "address"
              expect( @emailParsed[key] ).not.toEqual @email

  describe "Instance Methods", ->
    describe "#sendEmail", ->
      beforeEach ->
        @sendEmailURL = "/api/v1/email_accounts/send_email"
        @postStub = sinon.stub($, "post", ->)
  
        @email = new TuringEmailApp.Models.Email()
        @email.tos = ["test@turinginc.com"]
  
        @email.sendEmail()
  
      afterEach ->
        @postStub.restore()
  
      it "sends the email", ->
        expect(@postStub).toHaveBeenCalledWith(@sendEmailURL, @email.toJSON(), undefined, "json")

    describe "#sendLater", ->
      beforeEach ->
        @sendEmailURL = "/api/v1/email_accounts/send_email_delayed"
        @postStub = sinon.stub($, "post", ->)

        @date = new Date().toString()
        @email = new TuringEmailApp.Models.Email()
        @email.tos = ["test@turinginc.com"]

        @data = @email.toJSON()
        @data["sendAtDateTime"] = @date

        @email.sendLater(@date)

      afterEach ->
        @postStub.restore()

      it "sends the email", ->
        expect(@postStub).toHaveBeenCalledWith(@sendEmailURL, @data, undefined, "json")
        
    describe "#localDateString", ->
      beforeEach ->
        @localDateStringSpy = sinon.spy(TuringEmailApp.Models.Email, "localDateString")

        @email = new TuringEmailApp.Models.Email(FactoryGirl.create("Email"))
        @email.localDateString()

      afterEach ->
        @localDateStringSpy.restore()
        
      it "calls the localDateString class method", ->
        expect(@localDateStringSpy).toHaveBeenCalledWith(@email.get("date"))
