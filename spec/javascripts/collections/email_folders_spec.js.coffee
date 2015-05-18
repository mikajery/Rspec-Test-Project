describe "EmailFoldersCollection", ->
  beforeEach ->
    @emailFoldersCollection = new TuringEmailApp.Collections.EmailFoldersCollection(undefined,
      app: TuringEmailApp
      demoMode: false
    )

  it "has the right url", ->
    expect(@emailFoldersCollection.url).toEqual("/api/v1/email_folders")
    
  it "should use the EmailFolder model", ->
    expect(@emailFoldersCollection.model).toEqual TuringEmailApp.Models.EmailFolder
    
  describe "#initialize", ->
    describe "demo mode defaults to true", ->
      beforeEach ->
        @emailFoldersCollectionTemp = new TuringEmailApp.Collections.EmailFoldersCollection(undefined,
          app: TuringEmailApp
        )
        
      it "demoMode=true", ->
        expect(@emailFoldersCollectionTemp.demoMode).toEqual(true)

    describe "assigns demoMode from the parameter", ->
      beforeEach ->
        @emailFoldersCollectionTemp = new TuringEmailApp.Collections.EmailFoldersCollection(undefined,
          app: TuringEmailApp
          demoMode: false
        )

      it "demoMode=false", ->
        expect(@emailFoldersCollectionTemp.demoMode).toEqual(false)
    
  describe "Network", ->
    describe "#sync", ->
      beforeEach ->
        @superStub = sinon.stub(TuringEmailApp.Collections.EmailFoldersCollection.__super__, "sync")
        @googleRequestStub = sinon.stub(window, "googleRequest", ->)
        @triggerStub = sinon.stub(@emailFoldersCollection, "trigger", ->)
  
      afterEach ->
        @triggerStub.restore()
        @googleRequestStub.restore()
        @superStub.restore()
        
      describe "write", ->
        beforeEach ->
          @method = "write"
          @collection = {}
          @options = {}
          
          @emailFoldersCollection.sync(@method, @collection, @options)
          
        it "calls super", ->
          expect(@superStub).toHaveBeenCalledWith(@method, @collection, @options)
          
        it "does NOT call googleRequest", ->
          expect(@googleRequestStub).not.toHaveBeenCalled()

        it "does not trigger the request event", ->
          expect(@triggerStub).not.toHaveBeenCalled()          
      
      describe "read", ->
        beforeEach ->
          @method = "read"
          @collection = {}

        describe "demoMode=true", ->
          beforeEach ->
            @options = error: sinon.stub()
          
            @emailFoldersCollection.demoMode = true
            @emailFoldersCollection.sync(@method, @collection, @options)
            
          it "calls super", ->
            expect(@superStub).toHaveBeenCalledWith(@method, @collection, @options)

          it "does NOT call googleRequest", ->
            expect(@googleRequestStub).not.toHaveBeenCalled()
  
          it "does not trigger the request event", ->
            expect(@triggerStub).not.toHaveBeenCalled()

        describe "demoMode=false", ->
          beforeEach ->
            @options = error: sinon.stub()
            
            @emailFoldersCollection.demoMode = false
            @emailFoldersCollection.sync(@method, @collection, @options)
            
          it "does not call super", ->
            expect(@superStub).not.toHaveBeenCalled()
            
          it "calls googleRequest", ->
            expect(@googleRequestStub.args[0][0]).toEqual(TuringEmailApp)
            specCompareFunctions((=> @labelsListRequest()), @googleRequestStub.args[0][1])
            specCompareFunctions(((response) => @loadLabels(response.result.labels, options)), @googleRequestStub.args[0][2])
            expect(@googleRequestStub.args[0][3]).toEqual(@options.error)
  
          it "triggers the request event", ->
            expect(@triggerStub).toHaveBeenCalledWith("request", @collection, null, @options)

    describe "#labelsListRequest", ->
      beforeEach ->
        window.gapi = client: gmail: users: labels: list: ->
        
        @ret = {}
        @labelsListStub = sinon.stub(gapi.client.gmail.users.labels, "list", => return @ret)

        @returned = @emailFoldersCollection.labelsListRequest()
      
      afterEach ->
        @labelsListStub.restore()
        
      it "prepares and returns the Gmail API request", ->
        expect(@labelsListStub).toHaveBeenCalledWith(userId: "me", fields: "labels/id")
        expect(@returned).toEqual(@ret)

    describe "#loadLabels", ->
      beforeEach ->
        @googleRequestStub = sinon.stub(window, "googleRequest", ->)
        labelsListInfo = fixture.load("gmail_api/users.labels.list.fixture.json")[0]
        
        @error = sinon.stub()
        @emailFoldersCollection.loadLabels(labelsListInfo, error: @error)

      afterEach ->
        @googleRequestStub.restore()

      it "calls googleRequest", ->
        expect(@googleRequestStub.args[0][0]).toEqual(TuringEmailApp)
        specCompareFunctions((=> @labelsGetBatch(labelsListInfo)), @googleRequestStub.args[0][1])
        specCompareFunctions(((response) => @processLabelsGetBatch(response, options)), @googleRequestStub.args[0][2])
        expect(@googleRequestStub.args[0][3]).toEqual(@error)

    describe "#labelsGetBatch", ->
      beforeEach ->
        @batch = add: =>
        @addStub = sinon.stub(@batch, "add", =>)
        
        window.gapi =
          client:
            newBatch: => @batch
              
            gmail: 
              users: 
                labels: get: ->

        @labelsGetStub = sinon.stub(gapi.client.gmail.users.labels, "get", (params) => params)

        @labelsListInfo = obj = [ { id: 3 } ]
        @returned = @emailFoldersCollection.labelsGetBatch(@labelsListInfo)
        
      it "adds the items to the batch", ->
        for labelInfo in @labelsListInfo
          params = userId: "me", id: labelInfo.id

          expect(@labelsGetStub).toHaveBeenCalledWith(params)
          expect(@addStub).toHaveBeenCalledWith(params)
        
      it "returns the batch", ->
        expect(@returned).toEqual(@batch)
      
    describe "#processLabelsGetBatch", ->
      beforeEach ->
        response = fixture.load("gmail_api/users.labels.get.batch.fixture.json")[0]
        labelsResults = _.values(response.result)
        @labelsInfo = _.pluck(labelsResults, "result")
        
        @success = sinon.stub()
        @emailFoldersCollection.processLabelsGetBatch(response, success: @success)
        
      it "calls success option with the labelsInfo", ->
        expect(@success).toHaveBeenCalledWith(@labelsInfo)
        
    describe "#parse", ->
      beforeEach ->
        @labelsInfo = fixture.load("gmail_api/users.labels.get.fixture.json")[0]
        @labelsParsed = fixture.load("gmail_api/users.labels.parsed.fixture.json")[0]

      describe "demoMode=true", ->
        beforeEach ->
          @emailFoldersCollection.demoMode = true
          @returned = @emailFoldersCollection.parse(@labelsInfo)
          
        it "returns the unparsed labels", ->
          expect(@returned).toEqual(@labelsInfo)
          
      describe "demoMode=false", ->
        beforeEach ->
          @emailFoldersCollection.demoMode = false
          
        it "returns the parsed labels", ->
          @returned = @emailFoldersCollection.parse(@labelsInfo)
          expect(@returned).toEqual(@labelsParsed)

        describe "although the labels info item includes error", ->
          beforeEach ->
            @labelsInfo.push({"error": true})

          it "returns the parsed labels", ->
            @returned = @emailFoldersCollection.parse(@labelsInfo)
            expect(@returned).toEqual(@labelsParsed)          

