describe "CollectionView", ->
  beforeEach ->
    @collection = new Backbone.Collection([{}])
    @collectionView = new TuringEmailApp.Views.CollectionView(collection: @collection)

  describe "#initialize", ->
    describe "Collection Event Hooks", ->
      beforeEach ->
        @renderStub = sinon.stub(@collectionView, "render")

      afterEach ->
        @renderStub.restore()

      describe "#add", ->
        beforeEach ->
          @collection.add({})

        afterEach ->
          @collection.reset()

        it "calls render", ->
          expect(@renderStub).toHaveBeenCalled()

      describe "#remove", ->
        beforeEach ->
          @collection.remove(@collection.at(0))

        afterEach ->
          @collection.reset()

        it "calls render", ->
          expect(@renderStub).toHaveBeenCalled()

      describe "#reset", ->
        beforeEach ->
          @collection.reset()

        afterEach ->
          @collection.reset()

        it "calls render", ->
          expect(@renderStub).toHaveBeenCalled()

      describe "#destroy", ->
        beforeEach ->
          @server = sinon.fakeServer.create()
          @collection.at(0).destroy()

        afterEach ->
          @collection.reset()
          @server.restore()

        it "calls render", ->
          expect(@renderStub).toHaveBeenCalled()
  