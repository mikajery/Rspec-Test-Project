describe "ListSubscriptionsView", ->
  beforeEach ->
    specStartTuringEmailApp()

    @listSubscriptions = new TuringEmailApp.Collections.ListSubscriptionsCollection(FactoryGirl.createLists("ListSubscription", FactoryGirl.SMALL_LIST_SIZE))
    @listSubscriptions.at(1).set("unsubscribed", true)
    @listSubscriptionsView = new TuringEmailApp.Views.PrimaryPane.ListSubscriptionsView(collection: @listSubscriptions)

  afterEach ->
    specStopTuringEmailApp()

  it "has the right template", ->
    expect(@listSubscriptionsView.template).toEqual JST["backbone/templates/primary_pane/list_subscriptions"]

  it "has the right events", ->
    expect(@listSubscriptionsView.events["click .unsubscribe-list-button"]).toEqual "onUnsubscribeListClick"
    expect(@listSubscriptionsView.events["click .resubscribe-list-button"]).toEqual "onResubscribeListClick"
    expect(@listSubscriptionsView.events["click .list-subscription-pagination .next-list-subscription-page"]).toEqual "nextSubscriptionPage"
    expect(@listSubscriptionsView.events["click .list-subscription-pagination .previous-list-subscription-page"]).toEqual "previousSubscriptionPage"
    expect(@listSubscriptionsView.events["click .list-unsubscription-pagination .next-list-unsubscription-page"]).toEqual "nextUnsubscriptionPage"
    expect(@listSubscriptionsView.events["click .list-unsubscription-pagination .previous-list-unsubscription-page"]).toEqual "previousUnsubscriptionPage"

  describe "#render", ->

    describe "when the tab ID is selected", ->
      beforeEach ->
        @selectedTabID = "tab-1"
        $('body').append('<div class="tm_content-tab-pane active" id="' + @selectedTabID + '"></div>')

        @listSubscriptionsView.render()

      afterEach ->
        $("#" + @selectedTabID).remove()

  describe "after render", ->
    beforeEach ->
      @listSubscriptionsView.render()

    describe "#onUnsubscribeListClick", ->
      beforeEach ->
        @event =
          currentTarget: $(@listSubscriptionsView.$el.find(".unsubscribe-list-button")[0])
          preventDefault: ->

        @triggerStub = sinon.stub(@listSubscriptionsView, "trigger", ->)

        @listSubscriptionsView.onUnsubscribeListClick(@event)

      afterEach ->
        @triggerStub.restore()

      it "triggers unsubscribeListClicked", ->
        expect(@triggerStub).toHaveBeenCalledWith("unsubscribeListClicked", @listSubscriptionsView, @listSubscriptions.at(0))

    describe "#onResubscribeListClick", ->
      beforeEach ->
        @event =
          currentTarget: $(@listSubscriptionsView.$el.find(".resubscribe-list-button")[0])
          preventDefault: ->

        @triggerStub = sinon.stub(@listSubscriptionsView, "trigger", ->)

        @listSubscriptionsView.onResubscribeListClick(@event)

      afterEach ->
        @triggerStub.restore()

      it "triggers resubscribeListClicked", ->
        expect(@triggerStub).toHaveBeenCalledWith("resubscribeListClicked", @listSubscriptionsView, @listSubscriptions.at(1))
