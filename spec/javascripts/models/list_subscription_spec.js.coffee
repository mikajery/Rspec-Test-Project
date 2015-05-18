describe "ListSubscription", ->
  describe "Class Functions", ->
    describe "#Unsubscribe", ->
      beforeEach ->
        @listSubscription =
          toJSON: sinon.stub()
        
        @json = {}
        @listSubscription.toJSON.returns(@json)

        @ajaxStub = sinon.stub($, "ajax", ->)

        TuringEmailApp.Models.ListSubscription.Unsubscribe(@listSubscription)

      afterEach ->
        @ajaxStub.restore()

      it "submits the DELETE", ->
        expect(@ajaxStub).toHaveBeenCalledWith(
          url: "/api/v1/list_subscriptions/unsubscribe"
          type: "DELETE"
          data: @json
        )
        
    describe "#Resubscribe", ->
      beforeEach ->
        @listSubscription =
          toJSON: sinon.stub()
        
        @json = {}
        @listSubscription.toJSON.returns(@json)
          
        @postStub = sinon.stub($, "post", ->)

        TuringEmailApp.Models.ListSubscription.Resubscribe(@listSubscription)

      afterEach ->
        @postStub.restore()

      it "submits the POST", ->
        expect(@postStub).toHaveBeenCalledWith("/api/v1/list_subscriptions/resubscribe", @json)
