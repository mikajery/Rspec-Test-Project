describe "EmailDraft", ->
  beforeEach ->
    @emailDraft = new TuringEmailApp.Models.EmailDraft()
    @draftID = "id"
    @emailDraft.set("draft_id", @draftID)

  describe "Class Functions", ->
    describe "#sendDraftRequest", ->
      beforeEach ->
        window.gapi = client: gmail: users: drafts: send: ->
    
        @ret = {}
        @sendDraftStub = sinon.stub(gapi.client.gmail.users.drafts, "send", => return @ret)
    
        @params = userId: "me"
        @body = id: "draft id"
    
        @returned = TuringEmailApp.Models.EmailDraft.sendDraftRequest(@body.id)
    
      afterEach ->
        @sendDraftStub.restore()
  
      it "prepares and returns the Gmail API request", ->
        expect(@sendDraftStub).toHaveBeenCalledWith(@params, @body)
        expect(@returned).toEqual(@ret)
    
    describe "#sendDraft", ->
      beforeEach ->
        @draftID = "id"
        @success = sinon.stub()
        @error = sinon.stub()

        @googleRequestStub = sinon.stub(window, "googleRequest", ->)

        TuringEmailApp.Models.EmailDraft.sendDraft(TuringEmailApp, @draftID, @success, @error)

      afterEach ->
        @googleRequestStub.restore()

      it "calls googleRequest", ->
        expect(@googleRequestStub.args[0][0]).toEqual(TuringEmailApp)
        specCompareFunctions((=> TuringEmailApp.Models.EmailDraft.sendDraftRequest(draftID)), @googleRequestStub.args[0][1])
        expect(@googleRequestStub.args[0][2]).toEqual(@success)
        expect(@googleRequestStub.args[0][3]).toEqual(@error)

  it "has the right url", ->
    expect(@emailDraft.url).toEqual("/api/v1/email_accounts/drafts")
        
  describe "#sendDraft", ->
    beforeEach ->
      @sendDraftStub = sinon.stub(TuringEmailApp.Models.EmailDraft, "sendDraft")
      @success = sinon.stub()
      @error = sinon.stub()
      
      @emailDraft.sendDraft(TuringEmailApp, @success, @error)
    
    afterEach ->
      @sendDraftStub.restore()
  
    it "sends the draft", ->
      expect(@sendDraftStub).toHaveBeenCalledWith(TuringEmailApp, @draftID, @success, @error)