describe "ListsReportView", ->
  beforeEach ->
    specStartTuringEmailApp()

    @listsReport = new TuringEmailApp.Models.Reports.ListsReport()

    @listsReportView = new TuringEmailApp.Views.PrimaryPane.Analytics.Reports.ListsReportView(
      model: @listsReport
    )

    listsReportFixtures = fixture.load("reports/lists_report.fixture.json", true);
    @listsReportFixture = listsReportFixtures[0]

    @server = sinon.fakeServer.create()

  afterEach ->
    @server.restore()

    specStopTuringEmailApp()

  it "has the right template", ->
    expect(@listsReportView.template).toEqual JST["backbone/templates/primary_pane/analytics/reports/lists_report"]

  describe "#render", ->
    beforeEach ->
      @server.respondWith "GET", new TuringEmailApp.Models.Reports.ListsReport().url, JSON.stringify(@listsReportFixture)
      @listsReport.fetch()
      @server.respond()

    it "renders the report", ->
      expect(@listsReportView.$el).toContainHtml("Lists")

      listReportStatsDiv = @listsReportView.$el.find(".list-report-statistics")
      expect(listReportStatsDiv).toContainHtml('<h5>Lists email daily average</h5>')
      expect(listReportStatsDiv).toContainHtml('<h5>Emails per list</h5>')
      expect(listReportStatsDiv).toContainHtml('<h5>Email threads per list</h5>')
      expect(listReportStatsDiv).toContainHtml('<h5>Email threads replied to per list</h5>')
      # expect(listReportStatsDiv).toContainHtml('<h5>Sent emails per list</h5>') TODO add sent emails to test data.
      # expect(listReportStatsDiv).toContainHtml('<h5>Sent emails replied to per list</h5>') TODO add sent emails replied to per list to test data.

  describe "when the first item in the list stats is null", ->
    beforeEach ->
      @server.respondWith "GET", new TuringEmailApp.Models.Reports.ListsReport().url, JSON.stringify(@listsReportFixture)
      @listsReport.fetch()
      @server.respond()

    it "renders the second list stat", ->
      # TODO figure out how to test the second list stat.
