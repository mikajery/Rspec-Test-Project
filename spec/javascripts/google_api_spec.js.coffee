describe "window.googleRequest", ->
  describe "when the app is defiend", ->
    beforeEach ->
      @app =
        gmailAPIReady: false

    it 'returns undefined', ->
      expect( window.googleRequest(@app, 2, 3, 4, 5) ).toBeUndefined()
      
    it 'sets timeout', ->
      setTimeoutStub = sinon.stub(window, "setTimeout")
      window.googleRequest(@app, 2, 3, 4, 5)
      expect(setTimeoutStub).toHaveBeenCalled()
      setTimeoutStub.restore()


  describe "when the generateRequest is successed", ->
    beforeEach ->
      @generateRequest = ->
        then: ->

    it 'makes the google request', ->
      request_then = ->
      callback = sinon.stub(this, 'generateRequest')
      callback.onCall(0).returns(then: request_then);
      window.googleRequest(undefined, @generateRequest, 3, 4, 5)
      expect(callback).toHaveBeenCalled()
      callback.restore()
