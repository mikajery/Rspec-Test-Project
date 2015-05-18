describe "BaseCollection", ->
  beforeEach ->
    @baseCollection = new TuringEmailApp.Collections.BaseCollection()

  describe "with models", ->
    beforeEach ->
      @baseCollection.add(FactoryGirl.createLists("App", FactoryGirl.SMALL_LIST_SIZE))

    describe "Events", ->
      describe "#modelRemoved", ->
        beforeEach ->
          @model = @baseCollection.at(0)
          @triggerStub = sinon.spy(@model, "trigger")

          @baseCollection.remove(@model)

        afterEach ->
          @triggerStub.restore()

        it "triggers removedFromCollection on the model", ->
          expect(@triggerStub).toHaveBeenCalledWith("removedFromCollection", @baseCollection)

      describe "#modelsReset", ->
        beforeEach ->
          @modelRemovedStub = sinon.stub(@baseCollection, "modelRemoved", ->)

          @oldModles = @baseCollection.models
          @models = FactoryGirl.createLists("App", FactoryGirl.SMALL_LIST_SIZE)
          @baseCollection.reset(@models)

        afterEach ->
          @modelRemovedStub.restore()

        it "calls modelRemoved for each model model removed", ->
          for model in @oldModles
            expect(@modelRemovedStub).toHaveBeenCalledWith(model)
