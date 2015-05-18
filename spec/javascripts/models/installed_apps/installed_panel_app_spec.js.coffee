describe "InstalledPanelApp", ->
  describe "Class Functions", ->
    describe "#GetEmailThreadAppJSON", ->
      beforeEach ->
        emailThreadAttributes = FactoryGirl.create("EmailThread")
        @emailThread = new TuringEmailApp.Models.EmailThread(emailThreadAttributes.toJSON(),
          app: TuringEmailApp
          emailThreadUID: emailThreadAttributes.uid
          demoMode: false
        )

        @cleanEmailAppJSONStub = sinon.stub(TuringEmailApp.Models.InstalledApps.InstalledPanelApp, "CleanEmailAppJSON")
        @emailThreadAppJSON = TuringEmailApp.Models.InstalledApps.InstalledPanelApp.GetEmailThreadAppJSON(@emailThread)
      
      afterEach ->
        @cleanEmailAppJSONStub .restore()

      it "cleans the email JSON", ->
        expect(@cleanEmailAppJSONStub).toHaveBeenCalledWith(email) for email in @emailThread.get("emails")
        
    describe "#CleanEmailAppJSON", ->
      beforeEach ->
        @email = new TuringEmailApp.Models.Email(FactoryGirl.create("Email"))
        
      describe "with email object", ->
        beforeEach ->
          @emailJSON = TuringEmailApp.Models.InstalledApps.InstalledPanelApp.CleanEmailAppJSON(@email)

        it "does not return the encoded properties", ->
          keys = _.keys(@emailJSON)
  
          expect(keys.indexOf("body_text_encoded")).toEqual(-1)
          expect(keys.indexOf("html_part_encoded")).toEqual(-1)
          expect(keys.indexOf("text_part_encoded")).toEqual(-1)

      describe "with email JSON", ->
        beforeEach ->
          @emailJSON = @email.toJSON()
          @emailJSON = TuringEmailApp.Models.InstalledApps.InstalledPanelApp.CleanEmailAppJSON(@emailJSON)

        it "does not return the encoded properties", ->
          keys = _.keys(@emailJSON)

          expect(keys.indexOf("body_text_encoded")).toEqual(-1)
          expect(keys.indexOf("html_part_encoded")).toEqual(-1)
          expect(keys.indexOf("text_part_encoded")).toEqual(-1)
  
  beforeEach ->
    installedAppJSON = FactoryGirl.create("InstalledPanelApp")
    @installedPanelApp = TuringEmailApp.Models.InstalledApps.InstalledApp.CreateFromJSON(installedAppJSON)
    
  describe "#run", ->
    beforeEach ->
      @iframe = $("<iframe></iframe>").appendTo("body")
      @server = sinon.fakeServer.create()
      @data = "<head></head><body>hi</body>"
      @server.respondWith "POST", @installedPanelApp.get("app").callback_url, @data
      
    afterEach ->
      @iframe.remove()
      
      @server.restore()
        
    describe "with email JSON", ->
      beforeEach ->
        @email = new TuringEmailApp.Models.Email(FactoryGirl.create("Email").toJSON())
        @emailJSON = @email.toJSON()
          
        TuringEmailApp.Models.InstalledApps.InstalledPanelApp.CleanEmailAppJSON(@emailJSON)
  
        @installedPanelApp.run(@iframe, @email.toJSON())

      it "posts the request", ->
        expect(@server.requests.length).toEqual(1)
  
        request = @server.requests[0]
        expect(request.method).toEqual("POST")
        expect(request.url).toEqual(@installedPanelApp.get("app").callback_url)
        expect(request.requestBody).toEqual($.param({email: @emailJSON}, false))
  
      it "updates the iframe on success", ->
        @server.respond()
        expect(@iframe.contents().find("html").html()).toEqual(@data)
      
    describe "with email thread", ->
      beforeEach ->
        emailThreadAttributes = FactoryGirl.create("EmailThread")
        @emailThread = new TuringEmailApp.Models.EmailThread(emailThreadAttributes.toJSON(),
          app: TuringEmailApp
          emailThreadUID: emailThreadAttributes.uid
          demoMode: false
        )
  
        @emailThreadAppJSON = TuringEmailApp.Models.InstalledApps.InstalledPanelApp.GetEmailThreadAppJSON(@emailThread)
  
        @installedPanelApp.run(@iframe, @emailThread)
        
      it "posts the request", ->
        expect(@server.requests.length).toEqual(1)
  
        request = @server.requests[0]
        expect(request.method).toEqual("POST")
        expect(request.url).toEqual(@installedPanelApp.get("app").callback_url)
        expect(request.requestBody).toEqual($.param({email_thread: @emailThreadAppJSON}, false))
        
      it "updates the iframe on success", ->
        @server.respond()
        expect(@iframe.contents().find("html").html()).toEqual(@data)
