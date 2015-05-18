describe "InboxEfficiencyReport", ->
  beforeEach ->
    inboxEfficiencyFixtures = fixture.load("reports/inbox_efficiency_report.fixture.json", true);
    @inboxEfficiencyFixture = inboxEfficiencyFixtures[0]

    @inboxEfficiencyReport = new TuringEmailApp.Models.Reports.InboxEfficiencyReport()

    @server = sinon.fakeServer.create()

    @url = "/api/v1/email_reports/inbox_efficiency_report"
    @server.respondWith "GET", @url, JSON.stringify(@inboxEfficiencyFixture)

  afterEach ->
    @server.restore()

  it "has the right url", ->
    # currently using fake data
    #expect(@inboxEfficiencyReport.url).toEqual @url

  describe "#fetch", ->
    beforeEach ->
      @inboxEfficiencyReport.fetch()
      @server.respond()

    it "loads the contacts report", ->
      validateKeys(@inboxEfficiencyReport.toJSON(), ["average_response_time_in_minutes", "percent_archived"])
