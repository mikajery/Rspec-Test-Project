describe "CreateFolderView", ->
  beforeEach ->
    specStartTuringEmailApp()

  afterEach ->
    specStopTuringEmailApp()

  it "has the right template", ->
    expect(TuringEmailApp.views.createFolderView.template).toEqual JST["backbone/templates/toolbar/create_folder"]

  describe "#render", ->
    beforeEach ->
      TuringEmailApp.views.createFolderView.render()
      
    it "calls setupCreateFolderView", ->
      spy = sinon.spy(TuringEmailApp.views.createFolderView, "setupCreateFolderView")
      TuringEmailApp.views.createFolderView.render()
      expect(spy).toHaveBeenCalled()
      spy.restore()

  describe "after render", ->
    beforeEach ->
      TuringEmailApp.views.createFolderView.render()

    describe "#setupCreateFolderView", ->
      it "binds the submit event to create-folder-form", ->
        expect(TuringEmailApp.views.createFolderView.$el.find(".create-folder-form")).toHandle("submit")

      describe "when the create folder form is submitted", ->
        beforeEach ->
          TuringEmailApp.views.createFolderView.folderType = "label"

        it "triggers createFolderFormSubmitted", ->
          spy = sinon.backbone.spy(TuringEmailApp.views.createFolderView, "createFolderFormSubmitted")
          TuringEmailApp.views.createFolderView.$el.find(".create-folder-form").submit()
          expect(spy).toHaveBeenCalled()
          spy.restore()

        it "hides the create folder modal", ->
          spy = sinon.spy(TuringEmailApp.views.createFolderView, "hide")
          TuringEmailApp.views.createFolderView.$el.find(".create-folder-form").submit()
          expect(spy).toHaveBeenCalled()
          spy.restore()

    describe "#show", ->
      describe "for label", ->
        beforeEach ->
          TuringEmailApp.views.createFolderView.show("label")
          
        it "sets the folderType", ->
          expect(TuringEmailApp.views.createFolderView.mode).toEqual("label")
          
        it "shows the create folder modal", ->
          expect($("body")).toContain(".modal-backdrop.fade.in")
      
      describe "for folder", ->
        beforeEach ->
          TuringEmailApp.views.createFolderView.show("folder")

        it "sets the folderType", ->
          expect(TuringEmailApp.views.createFolderView.mode).toEqual("folder")

        it "shows the create folder modal", ->
          expect($("body")).toContain(".modal-backdrop.fade.in")

    describe "#hide", ->

      it "hides the create folder modal", ->
        TuringEmailApp.views.createFolderView.hide()
        expect(TuringEmailApp.views.createFolderView.$el.find(".create-folder-modal").hasClass("in")).toBeFalsy()
