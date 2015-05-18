describe "InboxCleanerView", ->
  beforeEach ->
    specStartTuringEmailApp()

    @email = new TuringEmailApp.Models.Email(FactoryGirl.create("Email"))

    @model = new Backbone.Model(
      num_important_emails: 1
      important_emails: [@email]
      num_auto_filed_emails: 1
      auto_filed_emails: [@email]
    )

    @inboxCleanerView = new TuringEmailApp.Views.PrimaryPane.InboxCleanerView(
    	app: TuringEmailApp
    	model: @model
    )

  afterEach ->
    specStopTuringEmailApp()

  it "has the right template", ->
    expect(@inboxCleanerView.template).toEqual JST["backbone/templates/primary_pane/inbox_cleaner"]
