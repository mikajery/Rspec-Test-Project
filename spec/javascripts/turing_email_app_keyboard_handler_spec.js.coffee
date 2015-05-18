describe "TuringEmailAppKeyboardHandler", ->
  beforeEach ->
    specStartTuringEmailApp()
    
    @keyboardHandler = new TuringEmailAppKeyboardHandler(TuringEmailApp)

    @handlers =
      "keydown":
        "up": "moveSelectionUp"
        "down": "moveSelectionDown"

        "K": "moveSelectionUp"
        "J": "moveSelectionDown"

        "C": "showCompose"
        
        "R": "showReply"
        "F": "showForward"

        "E": "archiveEmail"
        "Y": "archiveEmail"

        "V": "showMoveToFolderMenu"

  afterEach ->
    specStopTuringEmailApp()

  describe "#constructor", ->
    it "saves the app variable", ->
      expect(@keyboardHandler.app).toEqual(TuringEmailApp)

    it "handles the events", ->
      for type, typeHandlers of @handlers
        events = _.keys(typeHandlers)
        expect(_.keys(@keyboardHandler.handlers[type]).sort()).toEqual(events.sort())      

  describe "#start", ->
      beforeEach ->
        @bindKeysStub = sinon.stub(@keyboardHandler, "bindKeys")
        @keyboardHandler.start()
        
      afterEach ->
        @bindKeysStub.restore()
        
      it "binds the keys", ->
        expect(@bindKeysStub).toHaveBeenCalled()

  describe "#stop", ->
    beforeEach ->
      @unbindKeysStub = sinon.stub(@keyboardHandler, "unbindKeys")
      @keyboardHandler.stop()

    afterEach ->
      @unbindKeysStub.restore()

    it "unbinds the keys", ->
      expect(@unbindKeysStub).toHaveBeenCalled()
        
  describe "#bindKeys", ->
    beforeEach ->
      @keyboardHandler.bindKeys()

    it "binds the handlers", ->
      for type, typeHandlers of @handlers
        for keys, callbackName of typeHandlers
          @spy = sinon.stub(@keyboardHandler, callbackName, ->)

          @event = jQuery.Event("keydown")
          
          if keys == "up"
            @event.which = $.ui.keyCode.UP
          else if keys == "down"
            @event.which = $.ui.keyCode.DOWN
          else
            @event.which = keys.charCodeAt(0)

          $(document).trigger(@event)
          
          expect(@spy).toHaveBeenCalled()
          
          @spy.restore()

  describe "#unbindKeys", ->
    beforeEach ->
      @keyboardHandler.bindKeys()
      @keyboardHandler.unbindKeys()

    it "unbinds the events", ->
      for type, typeHandlers of @handlers
        for keys, callbackName of typeHandlers
          @spy = sinon.stub(@keyboardHandler, callbackName, ->)

          @event = jQuery.Event("keydown")

          if keys == "up"
            @event.which = $.ui.keyCode.UP
          else if keys == "down"
            @event.which = $.ui.keyCode.DOWN
          else
            @event.which = keys.charCodeAt(0)

          $(document).trigger(@event)

          expect(@spy).not.toHaveBeenCalled()

          @spy.restore()
    
  describe "after start", ->
    beforeEach ->
      @keyboardHandler.start()
      
    afterEach ->
      @keyboardHandler.stop()
      
    describe "#moveSelectionUp", ->
      # TODO figure out how to test preventDefault - spyOnEvent isn't working
      
      beforeEach ->
        @event = jQuery.Event("keydown")
        
        @moveSelectionUpStub = sinon.stub(@keyboardHandler.app.views.emailThreadsListView, "moveSelectionUp")
        
        @keyboardHandler.moveSelectionUp(@event)

      afterEach ->
        @moveSelectionUpStub.restore()
        
      it "moves the selection up on the email threads list view", ->
        expect(@moveSelectionUpStub).toHaveBeenCalled()

    describe "#moveSelectionDown", ->
      # TODO figure out how to test preventDefault - spyOnEvent isn't working
      
      beforeEach ->
        @event = jQuery.Event("keydown")
        
        @moveSelectionDownStub = sinon.stub(@keyboardHandler.app.views.emailThreadsListView, "moveSelectionDown")
        
        @keyboardHandler.moveSelectionDown(@event)

      afterEach ->
        @moveSelectionDownStub.restore()

      it "moves the selection down on the email threads list view", ->
        expect(@moveSelectionDownStub).toHaveBeenCalled()

    describe "#showCompose", ->
      beforeEach ->
        @event = jQuery.Event("keydown")
        
        @loadEmptyStub = sinon.stub(@keyboardHandler.app.views.composeView, "loadEmpty")
        @showStub = sinon.stub(@keyboardHandler.app.views.composeView, "show")
  
        @keyboardHandler.showCompose(@event)
  
      afterEach ->
        @loadEmptyStub.restore()
        @showStub.restore()
  
      it "shows an empty compose view", ->
        expect(@loadEmptyStub).toHaveBeenCalled()
        expect(@showStub).toHaveBeenCalled()

    describe "#showReply", ->
      beforeEach ->
        @event = jQuery.Event("keydown")

        @replyClickedStub = sinon.stub(@keyboardHandler.app, "replyClicked")
  
        @keyboardHandler.showReply(@event)
  
      afterEach ->
        @replyClickedStub.restore()
  
      it "show the reply email view", ->
        expect(@replyClickedStub).toHaveBeenCalled()

    describe "#showForward", ->
      beforeEach ->
        @event = jQuery.Event("keydown")

        @forwardClickedStub = sinon.stub(@keyboardHandler.app, "forwardClicked")

        @keyboardHandler.showForward(@event)

      afterEach ->
        @forwardClickedStub.restore()

      it "show the forward email view", ->
        expect(@forwardClickedStub).toHaveBeenCalled()

    describe "#archiveEmail", ->
      beforeEach ->
        @event = jQuery.Event("keydown")
  
        @archiveClickedStub = sinon.stub(@keyboardHandler.app, "archiveClicked")
  
        @keyboardHandler.archiveEmail(@event)

      afterEach ->
        @archiveClickedStub.restore()
  
      it "calls the archive emails handler", ->
        expect(@archiveClickedStub).toHaveBeenCalled()

    describe "#showMoveToFolderMenu", ->
      beforeEach ->
        @event = jQuery.Event("keydown")
  
        @showMoveToFolderMenuStub = sinon.stub(@keyboardHandler.app.views.toolbarView, "showMoveToFolderMenu")
  
        @keyboardHandler.showMoveToFolderMenu(@event)
  
      afterEach ->
        @showMoveToFolderMenuStub.restore()
  
      it "shows the move to folder menu", ->
        expect(@showMoveToFolderMenuStub).toHaveBeenCalled()
