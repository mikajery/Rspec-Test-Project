describe "AnalyticsView", ->
  beforeEach ->
    specStartTuringEmailApp()

    @analyticsView = new TuringEmailApp.Views.PrimaryPane.Analytics.AnalyticsView()
    @server = specPrepareReportFetches()

  afterEach ->
    @server.restore()

    specStopTuringEmailApp()

  it "has the right template", ->
    expect(@analyticsView.template).toEqual JST["backbone/templates/primary_pane/analytics/analytics"]

  describe "#render", ->
    beforeEach ->
      @analyticsView.render()
      @server.respond()

    it "renders the attachment reports", ->
      reportDiv = @analyticsView.$el.find(".attachments_report")
      expect(reportDiv.length).toEqual(1)
      expect(reportDiv.html()).not.toEqual("")
