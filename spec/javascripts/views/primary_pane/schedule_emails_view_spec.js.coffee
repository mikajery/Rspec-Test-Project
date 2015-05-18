describe "ScheduleEmailsView", ->
  beforeEach ->
    specStartTuringEmailApp()

    @delayedEmails = new TuringEmailApp.Collections.DelayedEmailsCollection(FactoryGirl.createLists("DelayedEmail", FactoryGirl.SMALL_LIST_SIZE))
    @delayedEmailsView = new TuringEmailApp.Views.PrimaryPane.ScheduleEmailsView(collection: @delayedEmails)

  afterEach ->
    specStopTuringEmailApp()

  it "has the right template", ->
    expect(@delayedEmailsView.template).toEqual JST["backbone/templates/primary_pane/schedule_emails"]

  it "has the right events", ->
    expect(@delayedEmailsView.events["click .new-delayed-email-button"]).toEqual "onNewDelayedEmailClick"
    expect(@delayedEmailsView.events["click .edit-delayed-email-button"]).toEqual "onEditDelayedEmailClick"
    expect(@delayedEmailsView.events["click .delete-delayed-email-button"]).toEqual "onDeleteDelayedEmailClick"
    expect(@delayedEmailsView.events["click .period-dropdown .dropdown-menu a"]).toEqual "onPeriodFilterClick"

  it "has the right className", ->
    expect(@delayedEmailsView.className).toEqual "tm_content tm_content-with-toolbar"

  it "has the right default period Filter", ->
    expect(@delayedEmailsView.periodFilter).toEqual -1

  describe "Render", ->
    it "should render delayed emails as .tm_email divs", ->
      @delayedEmailsView.periodFilter = -1
      @delayedEmailsView.render()
      filteredCollection = @delayedEmailsView.collection
      expect(@delayedEmailsView.$el.find(".tm_email[data-uid]").length).toEqual filteredCollection.length

      @delayedEmailsView.periodFilter = 1
      @delayedEmailsView.render()
      filteredCollection = @delayedEmailsView.collection.filterByPeriod(1)
      expect(@delayedEmailsView.$el.find(".tm_email[data-uid]").length).toEqual filteredCollection.length

      @delayedEmailsView.periodFilter = 7
      @delayedEmailsView.render()
      filteredCollection = @delayedEmailsView.collection.filterByPeriod(7)
      expect(@delayedEmailsView.$el.find(".tm_email[data-uid]").length).toEqual filteredCollection.length

      @delayedEmailsView.periodFilter = 30
      @delayedEmailsView.render()
      filteredCollection = @delayedEmailsView.collection.filterByPeriod(30)
      expect(@delayedEmailsView.$el.find(".tm_email[data-uid]").length).toEqual filteredCollection.length

  describe "Events", ->
    beforeEach ->
      @delayedEmailsView.render()

    it "should load new compose() dialog when .new-delayed-email-button is clicked", ->
      button = $(@delayedEmailsView.$el.find(".new-delayed-email-button")[0])
      button.prop("disabled", false)

      newStub = sinon.stub TuringEmailApp.views.mainView, "composeWithSendLaterDatetime", ->

      button.click()

      expect(newStub).toHaveBeenCalled()

    it "should trigger destroy() when .delete-delayed-email-button is clicked", ->
      button = $(@delayedEmailsView.$el.find(".delete-delayed-email-button")[0])
      uid = $(button).closest(".tm_email").data("uid")
      email = @delayedEmails.get uid

      destroyStub = sinon.stub email, "destroy", ->
        deferred = $.Deferred()
        deferred.resolve()

        return deferred.promise()

      button.click()

      expect(destroyStub).toHaveBeenCalled()

    it "should load delayed email when .edit-delayed-email-button is clicked", ->
      button = $(@delayedEmailsView.$el.find(".edit-delayed-email-button")[0])
      uid = $(button).closest(".tm_email").data("uid")
      email = @delayedEmails.get uid

      editStub = sinon.stub TuringEmailApp.views.mainView, "loadEmailDelayed", ->

      button.click()

      expect(editStub).toHaveBeenCalledWith(email)

    it "should set filter days when period filter is clicked", ->
      @delayedEmailsView.$el.find(".period-dropdown .dropdown-menu a[data-days='7']").click()
      expect(@delayedEmailsView.periodFilter).toEqual 7

      @delayedEmailsView.$el.find(".period-dropdown .dropdown-menu a[data-days='30']").click()
      expect(@delayedEmailsView.periodFilter).toEqual 30

      @delayedEmailsView.$el.find(".period-dropdown .dropdown-menu a[data-days='-1']").click()
      expect(@delayedEmailsView.periodFilter).toEqual -1
