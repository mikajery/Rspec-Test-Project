describe "EmailAttachment", ->
  describe "#Download", ->
    beforeEach ->
      @server = sinon.fakeServer.create()
      @clock  = sinon.useFakeTimers()
      @s3Key = "s3_key"
      @url = "/api/v1/email_attachments/download/" + @s3Key
      @email_attachment = new TuringEmailApp.Models.EmailAttachment()

    afterEach ->
      @server.restore()
      @clock.restore()

    describe "when downloads in progress", ->
      beforeEach ->
        TuringEmailApp.Models.EmailAttachment.DownloadsInProgress[@url] = "in progress"

      it "returns the undefined", ->

        expect( TuringEmailApp.Models.EmailAttachment.Download(TuringEmailApp, @s3Key) ).toBeUndefined

    describe "when downloads not in progress", ->
      beforeEach ->
        TuringEmailApp.Models.EmailAttachment.DownloadsInProgress[@url] = undefined    
        
      describe "when the ajax request is done", ->
        beforeEach ->              
          @server.respondWith "GET", @url, [ 200, "Content-Type": "application/json", "{\"url\":\"http\:\/\/google\.com\"}" ]
          TuringEmailApp.Models.EmailAttachment.Download(TuringEmailApp, @s3Key)
          @server.respond()

        it "downloads the file with the url", ->
          
          spy = sinon.spy(TuringEmailApp, 'downloadFile')

          expect(spy).toHaveBeenCalled

        it "deletes the url of the DownloadsInProgress", ->
          
          expect( TuringEmailApp.Models.EmailAttachment.DownloadsInProgress[@url] ).toBeUndefined

      describe "when the ajax request is failed", ->

        it "deletes the url of the DownloadsInProgress", ->
          @server.respondWith "GET", @url, [ 201, "Content-Type": "application/json", "{\"url\":\"http\:\/\/google\.com\"}" ]

          TuringEmailApp.Models.EmailAttachment.Download(TuringEmailApp, @s3Key)
          @server.respond()
          
          expect( TuringEmailApp.Models.EmailAttachment.DownloadsInProgress[@url] ).toBeUndefined

        describe "when the xhr status is 690", ->
          beforeEach ->          
            @server.respondWith "GET", @url, [ 690, "Content-Type": "application/json", "{\"url\":\"http\:\/\/google\.com\"}" ]

            TuringEmailApp.Models.EmailAttachment.Download(TuringEmailApp, @s3Key)

            @server.respond()

          afterEach ->
            TuringEmailApp.Models.EmailAttachment.Download.restore()
          
          it 'downloads', ->
            spy = sinon.spy(TuringEmailApp.Models.EmailAttachment, 'Download');

            @clock.tick(1)
            expect(spy).toHaveBeenCalled

        describe "when the xhr status is 691", ->
          beforeEach ->          
            @server.respondWith "GET", @url, [ 691, "Content-Type": "application/json", "{\"url\":\"http\:\/\/google\.com\"}" ]

            TuringEmailApp.Models.EmailAttachment.Download(TuringEmailApp, @s3Key)

            @server.respond()
          
          afterEach ->
            TuringEmailApp.showAlert.restore()

          it 'shows the alert', ->
            spy = sinon.spy(TuringEmailApp, 'showAlert')

            expect(spy).toHaveBeenCalled

        describe "when the xhr status is neither 690 nor 691", ->
          beforeEach ->          
            @server.respondWith "GET", @url, [ 500, "Content-Type": "application/json", "{\"url\":\"http\:\/\/google\.com\"}" ]

            TuringEmailApp.Models.EmailAttachment.Download(TuringEmailApp, @s3Key)

            @server.respond()

          afterEach ->
            TuringEmailApp.showAlert.restore()
          
          it 'shows the alert', ->
            spy = sinon.spy(TuringEmailApp, 'showAlert')

            expect(spy).toHaveBeenCalled