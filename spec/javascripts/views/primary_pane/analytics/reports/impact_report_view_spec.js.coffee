describe "ImpactReportView", ->
  beforeEach ->
    specStartTuringEmailApp()

    @impactReport = new TuringEmailApp.Models.Reports.ImpactReport()

    @impactReportView = new TuringEmailApp.Views.PrimaryPane.Analytics.Reports.ImpactReportView(
      model: @impactReport
    )

    impactReportFixtures = fixture.load("reports/impact_report.fixture.json", true);
    @impactReportFixture = impactReportFixtures[0]

    @server = sinon.fakeServer.create()
    @server.respondWith "GET", new TuringEmailApp.Models.Reports.ImpactReport().url, JSON.stringify(@impactReportFixture)

  afterEach ->
    @server.restore()

    specStopTuringEmailApp()

  it "has the right template", ->
    expect(@impactReportView.template).toEqual JST["backbone/templates/primary_pane/analytics/reports/impact_report"]

  describe "#render", ->
    beforeEach ->
      @impactReport.fetch()
      @server.respond()

    it "renders the report", ->
      expect(@impactReportView.$el).toContainHtml("Impact")

    it "renders the percent of sent emails replied to", ->
      expect(@impactReportView.$el).toContainHtml('<h4 class="h4">Percent of sent emails replied to: <small>' +
                                             @impactReport.get("percent_sent_emails_replied_to") * 100 +
                                             '%</small></h4>')
