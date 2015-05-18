describe "EmailThreadsCollection", ->
  beforeEach ->
    @emailThreadsCollection = new TuringEmailApp.Collections.EmailThreadsCollection(undefined,
      app: TuringEmailApp
      demoMode: false
    )

  it "has the right url", ->
    expect(@emailThreadsCollection.url).toEqual("/api/v1/email_threads/in_folder?folder_id=INBOX")
    
  it "should use the EmailThread model", ->
    expect(@emailThreadsCollection.model).toEqual(TuringEmailApp.Models.EmailThread)

  describe "#initialize", ->
    beforeEach ->
      @emailThreadsCollectionTemp = new TuringEmailApp.Collections.EmailThreadsCollection(undefined,
        app: TuringEmailApp
        folderID: "INBOX"
      )

    it "initializes the variables", ->
      expect(@emailThreadsCollectionTemp.app).toEqual(TuringEmailApp)
      expect(@emailThreadsCollectionTemp.pageTokens).toEqual([null])
      expect(@emailThreadsCollectionTemp.pageTokenIndex).toEqual(0)
      expect(@emailThreadsCollectionTemp.folderID).toEqual("INBOX")

    describe "demo mode defaults to true", ->
      beforeEach ->
        @emailThreadsCollectionTemp = new TuringEmailApp.Collections.EmailThreadsCollection(undefined,
          app: TuringEmailApp
          folderID: "INBOX"
        )

      it "demoMode=true", ->
        expect(@emailThreadsCollectionTemp.demoMode).toEqual(true)

    describe "assigns demoMode from the parameter", ->
      beforeEach ->
        @emailThreadsCollectionTemp = new TuringEmailApp.Collections.EmailThreadsCollection(undefined,
          app: TuringEmailApp
          demoMode: false
          folderID: "INBOX"
        )

      it "demoMode=false", ->
        expect(@emailThreadsCollectionTemp.demoMode).toEqual(false)
    
  describe "Network", ->
    describe "#sync", ->
      beforeEach ->
        @emailThreadsCollection.folderIDIs("INBOX")
        
        @superStub = sinon.stub(TuringEmailApp.Collections.EmailThreadsCollection.__super__, "sync")
        @googleRequestStub = sinon.stub(window, "googleRequest", ->)
        @triggerStub = sinon.stub(@emailThreadsCollection, "trigger", ->)

      afterEach ->
        @triggerStub.restore()
        @googleRequestStub.restore()
        @superStub.restore()

      describe "write", ->
        beforeEach ->
          @method = "write"
          @collection = {}
          @options = {}

          @emailThreadsCollection.sync(@method, @collection, @options)

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

            @emailThreadsCollection.demoMode = true
            @emailThreadsCollection.sync(@method, @collection, @options)

          it "calls super", ->
            expect(@superStub).toHaveBeenCalledWith(@method, @collection, @options)
  
          it "does NOT call googleRequest", ->
            expect(@googleRequestStub).not.toHaveBeenCalled()
  
          it "does not trigger the request event", ->
            expect(@triggerStub).not.toHaveBeenCalled()

        describe "demoMode=false", ->
          beforeEach ->
            @emailThreadsCollection.demoMode = false

          describe "when the options is not null", ->
            beforeEach ->
              @options = error: sinon.stub()
              @emailThreadsCollection.sync(@method, @collection, @options)

            it "does not call super", ->
              expect(@superStub).not.toHaveBeenCalled()
    
            it "sets the folderID", ->
              expect(@options.folderID).toEqual(@emailThreadsCollection.folderID)
    
            it "calls googleRequest", ->
              expect(@googleRequestStub.args[0][0]).toEqual(TuringEmailApp)
              specCompareFunctions((=> @threadsListRequest(options)), @googleRequestStub.args[0][1])
              specCompareFunctions(((response) => @processThreadsListRequest(response, options)), @googleRequestStub.args[0][2])
              expect(@googleRequestStub.args[0][3]).toEqual(@options.error)
    
            it "triggers the request event", ->
              expect(@triggerStub).toHaveBeenCalledWith("request", @collection, null, @options)

          describe "when the options is null", ->
            beforeEach ->
              @options = null
              @emailThreadsCollection.sync(@method, @collection, @options)

            it "converts null to the object", ->
              expect(@triggerStub).toHaveBeenCalledWith("request", @collection, null)

    describe "#threadsListRequest", ->
      describe "when the folderID is DRAFT", ->
        beforeEach ->
          window.gapi = client: gmail: users: drafts: list: ->

          @ret = {}
          @draftsListStub = sinon.stub(gapi.client.gmail.users.drafts, "list", => return @ret)

          @params =
            userId: "me"
            maxResults: TuringEmailApp.Models.UserConfiguration.EmailThreadsPerPage
            fields: "nextPageToken,threads(id)"

          @emailThreadsCollection.folderIDIs("DRAFT")
          @params["labelIds"] = @emailThreadsCollection.folderID
          
          @returned = @emailThreadsCollection.threadsListRequest(folderID: "DRAFT")

        afterEach ->
          @draftsListStub.restore()
          

        it "prepares and returns the Gmail API request", ->
          expect(@draftsListStub).toHaveBeenCalled
          #expect(@returned).toEqual(@ret)

      describe "when the folderID is not DRAFT", ->
        beforeEach ->
          window.gapi = client: gmail: users: threads: list: ->

          @ret = {}
          @threadsListStub = sinon.stub(gapi.client.gmail.users.threads, "list", => return @ret)

          @params =
            userId: "me"
            maxResults: TuringEmailApp.Models.UserConfiguration.EmailThreadsPerPage
            fields: "nextPageToken,threads(id)"

        afterEach ->
          @threadsListStub.restore()

        describe "with folderID", ->
          beforeEach ->
            @emailThreadsCollection.folderIDIs("test")
            @params["labelIds"] = @emailThreadsCollection.folderID
            
            @returned = @emailThreadsCollection.threadsListRequest(folderID: "test")
          
          it "prepares and returns the Gmail API request", ->
            expect(@threadsListStub).toHaveBeenCalledWith(@params)
            expect(@returned).toEqual(@ret)

        describe "with pageToken", ->
          beforeEach ->
            @emailThreadsCollection.pageTokens[0] = "token"
            @params["pageToken"] = @emailThreadsCollection.pageTokens[0]
            
            @returned = @emailThreadsCollection.threadsListRequest({})

          it "prepares and returns the Gmail API request", ->
            expect(@threadsListStub).toHaveBeenCalledWith(@params)
            expect(@returned).toEqual(@ret)

        describe "with query", ->
          beforeEach ->
            @params["q"] = "test"
            
            @returned = @emailThreadsCollection.threadsListRequest(query: "test")
            
          it "prepares and returns the Gmail API request", ->
            expect(@threadsListStub).toHaveBeenCalledWith(@params)
            expect(@returned).toEqual(@ret)
            
    describe "#processThreadsListRequest", ->
      beforeEach ->
        @options = {success: sinon.stub()}
        @loadThreadsStub = sinon.stub(@emailThreadsCollection, "loadThreads", ->)
        @loadDraftsStub = sinon.stub(@emailThreadsCollection, "loadDrafts", ->)
        
      afterEach ->
        @loadDraftsStub.restore()
        @loadThreadsStub.restore()

      describe "with threads", ->
        beforeEach ->
          @response = fixture.load("gmail_api/users.threads.list.fixture.json")[0]
          
          @emailThreadsCollection.processThreadsListRequest(@response, @options)

        it "updates the page tokens", ->
          expect(@emailThreadsCollection.pageTokens).toEqual([null, @response.result.nextPageToken])

        it "loads the threads", ->
          expect(@loadThreadsStub).toHaveBeenCalledWith(@response.result.threads, @options)

        it "does NOT load the drafts", ->
          expect(@loadDraftsStub).not.toHaveBeenCalled()
          
        it "does not call success", ->
          expect(@options.success).not.toHaveBeenCalled()

      describe "with drafts", ->
        beforeEach ->
          @response = fixture.load("gmail_api/users.drafts.list.fixture.json")[0]

          @emailThreadsCollection.processThreadsListRequest(@response, @options)

        it "updates the page tokens", ->
          expect(@emailThreadsCollection.pageTokens).toEqual([null])

        it "does NOT load the threads", ->
          expect(@loadThreadsStub).not.toHaveBeenCalled()
          
        it "loads the drafts", ->
          expect(@loadDraftsStub).toHaveBeenCalledWith(@response.result.drafts, @options)

        it "does not call success", ->
          expect(@options.success).not.toHaveBeenCalled()
          
      describe "without threads or drafts", ->
        beforeEach ->
          @response = result: {}

          @emailThreadsCollection.processThreadsListRequest(@response, @options)
          
        it "updates the page tokens", ->
          expect(@emailThreadsCollection.pageTokens).toEqual([null])
        
        it "does NOT load the drafts", ->
          expect(@loadDraftsStub).not.toHaveBeenCalled()
          
        it "does not load the threads", ->
          expect(@loadThreadsStub).not.toHaveBeenCalled()
          
        it "calls success", ->
          expect(@options.success).toHaveBeenCalledWith([])

    describe "#loadThreads", ->
      describe "with the options query", ->
        beforeEach ->
          @server = sinon.fakeServer.create()
          @success = sinon.stub()
          @error = sinon.stub()          
          @threadsListInfo = id: "14934f337d81083a"
          emailThreadUIDs = _.pluck(@threadsListInfo, "id")
          @postSpy = sinon.spy($, "post")          
          @url = "/api/v1/email_threads/retrieve"
          @postData =
            email_thread_uids: emailThreadUIDs

        afterEach ->          
          @postSpy.restore()
          @server.restore()
          
        it "posts", ->
          @emailThreadsCollection.loadThreads(@threadsListInfo, query: true)
          expect(@postSpy).toHaveBeenCalledWith(@url, @postData)

        describe "success", ->
          describe "when the success is function", ->
            beforeEach ->
              @emailThreadsCollection.loadThreads(@threadsListInfo, query: true, success: @success)  
              @server.respondWith("POST", @url, "")
              
            it "calls success", ->
              #expect(@success).toHaveBeenCalled()
              expect(@error).not.toHaveBeenCalled()
          describe "when the success is not function", ->
            it "returns undefined", ->
              expect( @emailThreadsCollection.loadThreads(@threadsListInfo, query: true) ).toBeUndefined
         
        describe "fail", ->
          describe "when the error is function", ->
            beforeEach ->
              @emailThreadsCollection.loadThreads(@threadsListInfo, query: true, error: @error)  
              @server.respond()
              
            it "calls error", ->
              expect(@success).not.toHaveBeenCalled()
              expect(@error).toHaveBeenCalled()
          describe "when the error is not function", ->
            it "returns undefined", ->
              expect( @emailThreadsCollection.loadThreads(@threadsListInfo, query: true) ).toBeUndefined
          
      describe "with no options query", ->
        beforeEach ->
          @googleRequestStub = sinon.stub(window, "googleRequest", ->)
          threadsListResponse = fixture.load("gmail_api/users.threads.list.fixture.json")[0]
          threadsListInfo = threadsListResponse.result.threads

          @error = sinon.stub()
          @emailThreadsCollection.loadThreads(threadsListInfo, error: @error)

        afterEach ->
          @googleRequestStub.restore()

        it "calls googleRequest", ->
          expect(@googleRequestStub.args[0][0]).toEqual(TuringEmailApp)
          specCompareFunctions((=> @threadsGetBatch(threadsListInfo)), @googleRequestStub.args[0][1])
          specCompareFunctions(((response) => @processThreadsGetBatch(response, options)), @googleRequestStub.args[0][2])
          expect(@googleRequestStub.args[0][3]).toEqual(@error)

    describe "#loadDrafts", ->
      beforeEach ->
        @googleRequestStub = sinon.stub(window, "googleRequest", ->)
        draftsListResponse = fixture.load("gmail_api/users.drafts.list.fixture.json")[0]
        @draftsListInfo = draftsListResponse.result.drafts

        @error = sinon.stub()
        @options = error: @error
        @emailThreadsCollection.loadDrafts(@draftsListInfo, @options)

      afterEach ->
        @googleRequestStub.restore()
        
      it "saves the drafts list info", ->
        expect(@options.draftsListInfo).toEqual(@draftsListInfo)

      it "calls googleRequest", ->
        expect(@googleRequestStub.args[0][0]).toEqual(TuringEmailApp)
        specCompareFunctions((=> @threadsGetBatch(threadsListInfo)), @googleRequestStub.args[0][1])
        specCompareFunctions(((response) => @processThreadsGetBatch(response, options)), @googleRequestStub.args[0][2])
        expect(@googleRequestStub.args[0][3]).toEqual(@error)
          
  describe "#threadsGetBatch", ->
    beforeEach ->
      @batch = add: =>
      @addStub = sinon.stub(@batch, "add", =>)

      window.gapi =
        client:
          newBatch: => @batch

          gmail:
            users:
              threads: get: ->

      @threadsGetStub = sinon.stub(gapi.client.gmail.users.threads, "get", (params) => params)

      threadsListResponse = fixture.load("gmail_api/users.threads.list.fixture.json")[0]
      @threadsListInfo = threadsListResponse.result.threads
      @returned = @emailThreadsCollection.threadsGetBatch(@threadsListInfo)

    it "adds the items to the batch", ->
      for threadInfo in @threadsListInfo
        params =
          userId: "me",
          id: threadInfo.id
          fields: "id,historyId,messages(id,labelIds)"

        expect(@threadsGetStub).toHaveBeenCalledWith(params)
        expect(@addStub).toHaveBeenCalledWith(params)

    it "returns the batch", ->
      expect(@returned).toEqual(@batch)
    
  describe "#processThreadsGetBatch", ->
    beforeEach ->
      response = fixture.load("gmail_api/users.threads.get.batch.fixture.json")[0]
      threadsResults = _.values(response.result)
      @threadsInfo = _.pluck(threadsResults, "result")

      @loadThreadsPreviewStub = sinon.stub(@emailThreadsCollection, "loadThreadsPreview", ->)
      @options = {}
      @emailThreadsCollection.processThreadsGetBatch(response, @options)
      
    afterEach ->
      @loadThreadsPreviewStub.restore()
    
    it "loads the thread previews", ->
      expect(@loadThreadsPreviewStub).toHaveBeenCalledWith(@threadsInfo, @options)
      
  describe "#loadThreadsPreview", ->
    beforeEach ->
      @googleRequestStub = sinon.stub(window, "googleRequest", ->)
      response = fixture.load("gmail_api/users.threads.get.batch.fixture.json")[0]
      threadsResults = _.values(response.result)
      @threadsInfo = _.pluck(threadsResults, "result")
    
      @error = sinon.stub()
      @emailThreadsCollection.loadThreadsPreview(@threadsInfo, error: @error)
    
    afterEach ->
      @googleRequestStub.restore()
  
    it "calls googleRequest", ->
      expect(@googleRequestStub.args[0][0]).toEqual(TuringEmailApp)
      specCompareFunctions((=> @messagesGetBatch(threadsInfo)), @googleRequestStub.args[0][1])
      specCompareFunctions(((response) => @processMessagesGetBatch(response, threadsInfo, options)),
                           @googleRequestStub.args[0][2])
      expect(@googleRequestStub.args[0][3]).toEqual(@error)
      
  describe "#messagesGetBatch", ->
    beforeEach ->
      @batch = add: =>
      @addStub = sinon.stub(@batch, "add", =>)

      window.gapi =
        client:
          newBatch: => @batch

          gmail:
            users:
              messages: get: ->

      @messagesGetStub = sinon.stub(gapi.client.gmail.users.messages, "get", (params) => params)

      response = fixture.load("gmail_api/users.threads.get.batch.fixture.json")[0]
      threadsResults = _.values(response.result)
      @threadsInfo = _.pluck(threadsResults, "result")
      @returned = @emailThreadsCollection.messagesGetBatch(@threadsInfo)

    it "adds the items to the batch", ->
      for threadInfo in @threadsInfo
        lastMessage =_.last(threadInfo.messages)
        
        params =
          userId: "me"
          id: lastMessage.id
          format: "metadata"
          metadataHeaders: ["date", "from", "subject"]
          fields: "payload,snippet"

        expect(@messagesGetStub).toHaveBeenCalledWith(params)
        expect(@addStub).toHaveBeenCalledWith(params)

    it "returns the batch", ->
      expect(@returned).toEqual(@batch)
      
  describe "#processMessagesGetBatch", ->
    describe "when the last message response status is 200", ->
      beforeEach ->
        threadsGetBatchResponse = fixture.load("gmail_api/users.threads.get.batch.fixture.json")[0]
        threadsResults = _.values(threadsGetBatchResponse.result)
        @threadsInfo = _.pluck(threadsResults, "result")

        @response = fixture.load("gmail_api/users.messages.get.batch.fixture.json")[0]
        @options = 
          success: sinon.stub()
          draftsListInfo:
            [
              message:
                threadId: "draft-id"
            ]
        
        @threadsParsed = fixture.load("gmail_api/users.threads.parsed.fixture.json")[0]

        @threadFromMessageInfoSpy = sinon.spy(@emailThreadsCollection, "threadFromMessageInfo")
        
        @emailThreadsCollection.processMessagesGetBatch(@response, @threadsInfo, @options)
        
      afterEach ->
        @threadFromMessageInfoSpy.restore()

      it "calls threadFromMessageInfo on each thread", ->
        for threadInfo in @threadsInfo
          lastMessage =_.last(threadInfo.messages)
          lastMessageResponse = @response.result[lastMessage.id]

          expect(@threadFromMessageInfoSpy).toHaveBeenCalledWith(threadInfo, lastMessageResponse.result)

      it "calls success with the parsed threads", ->
        expect(@options.success).toHaveBeenCalled()
        expect(JSON.stringify(@options.success.args[0][0])).toEqual(JSON.stringify(@threadsParsed))
    
    describe "when the last message response status is not 200", ->    
      beforeEach ->
        threadsGetBatchResponse = fixture.load("gmail_api/users.threads.get.batch.fixture.json")[0]
        threadsResults = _.values(threadsGetBatchResponse.result)
        @threadsInfo = _.pluck(threadsResults, "result")
        threadInfo = @threadsInfo[@threadsInfo.length-1]
        lastMessage =_.last(threadInfo.messages)

        @response = fixture.load("gmail_api/users.messages.get.batch.fixture.json")[0]
        @options = 
          success: sinon.stub()
          error: sinon.stub()
          draftsListInfo:
            [
              message:
                threadId: "draft-id"
            ]

        @response.result[lastMessage.id].status = 400
        @response.result[lastMessage.id].result = "custom result"
        @emailThreadsCollection.processMessagesGetBatch(@response, @threadsInfo, @options)
        

      it "calls success with the parsed threads", ->
        expect(@options.error).toHaveBeenCalledWith("custom result")
        
    

  describe "#threadFromMessageInfo", ->
    beforeEach ->
      threadsGetBatchResponse = fixture.load("gmail_api/users.threads.get.batch.fixture.json")[0]
      threadsResults = _.values(threadsGetBatchResponse.result)
      threadsInfo = _.pluck(threadsResults, "result")

      response = fixture.load("gmail_api/users.messages.get.batch.fixture.json")[0]
      @threadsParsed = fixture.load("gmail_api/users.threads.parsed.fixture.json")[0]

      threadInfo = _.find(threadsInfo, (threadInfo) =>
        return threadInfo.id == @threadsParsed[0].uid
      )
      lastMessage =_.last(threadInfo.messages)
      lastMessageResponse = response.result[lastMessage.id]
      @threadParsed = @emailThreadsCollection.threadFromMessageInfo(threadInfo, lastMessageResponse.result)
      
    it "parses the message into a thread", ->
      expect(JSON.stringify(@threadParsed)).toEqual(JSON.stringify(@threadsParsed[0]))

  describe "#parse", ->
    beforeEach ->
      @threadsJSON = [[], []]
      
    describe "demoMode=true", ->
      beforeEach ->
        @setThreadPropertiesFromJSONStub = sinon.stub(TuringEmailApp.Models.EmailThread, "SetThreadPropertiesFromJSON")
        @emailThreadsCollection.demoMode = true

        @emailThreadsCollection.parse(@threadsJSON)
        
      afterEach ->
        @setThreadPropertiesFromJSONStub.restore()

      it "updates the threadsJSON properties", ->
        expect(@setThreadPropertiesFromJSONStub).toHaveBeenCalledWith(threadJSON, true) for threadJSON in @threadsJSON

    describe "demoMode=false", ->
      beforeEach ->
        @emailThreadsCollection.demoMode = false

        @emailThreadsCollection.parse(@threadsJSON)
        
      it "sets demoMode to false on each threadJSON", ->
        for threadJSON in @threadsJSON
          expect(threadJSON.demoMode).toBeDefined()
          expect(threadJSON.demoMode).toBeFalsy()
    
  describe "with models", ->
    beforeEach ->
      @emailThreadsCollection.add(FactoryGirl.createLists("EmailThread", FactoryGirl.SMALL_LIST_SIZE))

    describe "Setters", ->
      describe "#resetPageTokens", ->
        beforeEach ->
          @oldPageTokens = @emailThreadsCollection.pageTokens
          @oldPageTokenIndex = @emailThreadsCollection.pageTokenIndex
          
          @emailThreadsCollection.resetPageTokens()

        afterEach ->
          @emailThreadsCollection.pageTokenIndex = @oldPageTokenIndex
          @emailThreadsCollection.pageTokens = @oldPageTokens
        
        it "resets the page tokens", ->
          expect(@emailThreadsCollection.pageTokens).toEqual([null])
        
        it "resets the page token index", ->
          expect(@emailThreadsCollection.pageTokenIndex).toEqual(0)
          
      describe "#folderIDIs", ->
        beforeEach ->
          @resetPageTokensStub = sinon.stub(@emailThreadsCollection, "resetPageTokens", ->)
          @setupURLStub = sinon.stub(@emailThreadsCollection, "setupURL", ->)
          @triggerStub = sinon.stub(@emailThreadsCollection, "trigger", ->)
          
        afterEach ->
          @triggerStub.restore()
          @resetPageTokensStub.restore()
          
        describe "demoMode=true", ->
          beforeEach ->
            @emailThreadsCollection.demoMode = true
            @emailThreadsCollection.folderIDIs(@emailThreadsCollection.folderID)

          it "calls setupURL", ->
            expect(@setupURLStub).toHaveBeenCalled()

        describe "demoMode=false", ->
          beforeEach ->
            @emailThreadsCollection.demoMode = false
            @emailThreadsCollection.folderIDIs(@emailThreadsCollection.folderID)

        it "does NOT call setupURL", ->
          expect(@setupURLStub).not.toHaveBeenCalled()
          
        describe "folder ID is equal to the current folder ID", ->
          beforeEach ->
            @emailThreadsCollection.folderIDIs(@emailThreadsCollection.folderID)
            
          it "does not reset the page tokens", ->
            expect(@resetPageTokensStub).not.toHaveBeenCalled()
            
          it "triggers the change:pageTokenIndex event", ->
            expect(@triggerStub).toHaveBeenCalledWith("change:folderID", @emailThreadsCollection, @emailThreadsCollection.folderID)

        describe "folder ID is NOT equal to the current folder ID", ->
          beforeEach ->
            @emailThreadsCollection.folderIDIs("test")
            
          it "does not reset the page tokens", ->
            expect(@resetPageTokensStub).toHaveBeenCalled()

          it "triggers the change:folderID event", ->
            expect(@triggerStub).toHaveBeenCalledWith("change:folderID", @emailThreadsCollection, "test")
    
      describe "pageTokenIndexIs", ->
        beforeEach ->
          @triggerStub = sinon.stub(@emailThreadsCollection, "trigger", ->)

        afterEach ->
          @triggerStub.restore()
          
        describe "when the page token index is in range", ->
          beforeEach ->
            @emailThreadsCollection.pageTokenIndexIs(0)
            
          it "updates the page token index", ->
            expect(@emailThreadsCollection.pageTokenIndex).toEqual(0)
        
          it "triggers the change:folderID event", ->
            expect(@triggerStub).toHaveBeenCalledWith("change:pageTokenIndex", @emailThreadsCollection, 0)
        
        describe "when the page token index is NOT in range", ->
          beforeEach ->
            @emailThreadsCollection.pageTokenIndexIs(1)

          it "updates the page token index", ->
            expect(@emailThreadsCollection.pageTokenIndex).toEqual(0)

          it "triggers the change:folderID event", ->
            expect(@triggerStub).toHaveBeenCalledWith("change:pageTokenIndex", @emailThreadsCollection, 0)
            
      describe "#setupURL", ->
        beforeEach ->
          @emailThreadsCollection.folderID = "test"
          
        it "set the correct URL", ->
          @emailThreadsCollection.setupURL("1", "ASC")
          expect(@emailThreadsCollection.url).toEqual("/api/v1/email_threads/in_folder?folder_id=test&last_email_thread_uid=1&dir=ASC")

      describe "#emailThreadsSeenIs", ->
        beforeEach ->
          @googleRequestStub = sinon.stub(window, "googleRequest", ->)
          @seenValue = true

        afterEach ->
          @googleRequestStub.restore()

        describe "demoMode=true", ->
          beforeEach ->
            @emailThreadsCollection.demoMode = true

            @postStub = sinon.stub($, "post")

            @postData = {}
            @postData.email_uids = _.reduce @emailThreadsCollection.models, ((uids, emailThread) ->
              uids.concat (email.uid for email in emailThread.get("emails"))
            ), []
            @postData.seen = @seenValue

            emailThreadUIDs = (emailThread.get("uid") for emailThread in @emailThreadsCollection.models)
            @emailThreadsCollection.emailThreadsSeenIs(emailThreadUIDs, @seenValue)

          afterEach ->
            @postStub.restore()

          it "does NOT call googleRequest", ->
            expect(@googleRequestStub).not.toHaveBeenCalled()

          it "posts", ->
            expect(@postStub).toHaveBeenCalledWith("/api/v1/emails/set_seen", @postData)

        describe "demoMode=false", ->
          beforeEach ->
            @emailThreadsCollection.demoMode = false
            emailThreadUIDs = (emailThread.get("uid") for emailThread in @emailThreadsCollection.models)
            @emailThreadsCollection.emailThreadsSeenIs(emailThreadUIDs, @seenValue)

          it "calls googleRequest", ->
            for emailThread in @emailThreadsCollection.models
              expect(@googleRequestStub).toHaveBeenCalled()
              expect(@googleRequestStub.args[0][0]).toEqual(TuringEmailApp)
              specCompareFunctions((-> emailThread.threadsModifyUnreadRequest(seenValue)), @googleRequestStub.args[0][1])

    describe "Getters", ->
      describe "#hasNextPage", ->
        beforeEach ->
          @oldPageTokens = @emailThreadsCollection.pageTokens
          @oldPageTokenIndex = @emailThreadsCollection.pageTokenIndex
          
        afterEach ->
          @emailThreadsCollection.pageTokenIndex = @oldPageTokenIndex
          @emailThreadsCollection.pageTokens = @oldPageTokens

        describe "demoMode=true", ->
          beforeEach ->
            @emailThreadsCollection.demoMode = true

          describe "has a next page", ->
            beforeEach ->
              @emailThreadsCollection.reset([])

            it "returns true", ->
              expect(@emailThreadsCollection.hasNextPage()).toBeTruthy()

          describe "does NOT have a next page", ->
            beforeEach ->
              @emailThreadsCollection.pageTokens = [null]

            it "returns false", ->
              expect(@emailThreadsCollection.hasNextPage()).toBeFalsy()
          
        describe "demoMode=false", ->
          beforeEach ->
            @emailThreadsCollection.demoMode = false
            @emailThreadsCollection.pageTokens = [null, "token"]
          
          describe "has a next page", ->
            beforeEach ->
              @emailThreadsCollection.pageTokenIndex = 0
              
            it "returns true", ->
              expect(@emailThreadsCollection.hasNextPage()).toBeTruthy()
  
          describe "does NOT have a next page", ->
            beforeEach ->
              @emailThreadsCollection.pageTokenIndex = 1
  
            it "returns false", ->
              expect(@emailThreadsCollection.hasNextPage()).toBeFalsy()

      describe "#hasPreviousPage", ->
        beforeEach ->
          @oldPageTokenIndex = @emailThreadsCollection.pageTokenIndex

        afterEach ->
          @emailThreadsCollection.pageTokenIndex = @oldPageTokenIndex

        describe "does NOT have a previous page", ->
          beforeEach ->
            @emailThreadsCollection.pageTokenIndex = 0

          it "returns false", ->
            expect(@emailThreadsCollection.hasPreviousPage()).toBeFalsy()

        describe "has a previous page", ->
          beforeEach ->
            @emailThreadsCollection.pageTokenIndex = 1

          it "returns true", ->
            expect(@emailThreadsCollection.hasPreviousPage()).toBeTruthy()
