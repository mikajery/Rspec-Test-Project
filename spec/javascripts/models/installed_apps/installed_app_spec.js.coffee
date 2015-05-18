describe "InstalledApp", ->
  describe "Class Functions", ->
    describe "#CreateFromJSON", ->
      describe "InstalledPanelApp", ->
        beforeEach ->
          installedAppJSON = FactoryGirl.create("InstalledPanelApp")
          @installedPanelApp = TuringEmailApp.Models.InstalledApps.InstalledApp.CreateFromJSON(installedAppJSON)
          
        it "creates the InstalledPanelApp", ->
          expect(@installedPanelApp instanceof TuringEmailApp.Models.InstalledApps.InstalledPanelApp).toBeTruthy()
          
    describe "#Uninstall", ->
      beforeEach ->
        @server = sinon.fakeServer.create()
  
        @appID = "1"
        TuringEmailApp.Models.InstalledApps.InstalledPanelApp.Uninstall(@appID)
  
      afterEach ->
        @server.restore()
  
      it "posts the uninstall request", ->
        expect(@server.requests.length).toEqual(1)
        
        request = @server.requests[0]
        expect(request.method).toEqual "DELETE"
        expect(request.url).toEqual "/api/v1/apps/uninstall/" + @appID
        expect(request.requestBody).toEqual(null)
   