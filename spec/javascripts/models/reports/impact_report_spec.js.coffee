describe "ImpactReport", ->
  beforeEach ->
    impactFixtures = fixture.load("reports/impact_report.fixture.json", true);
    @impactFixture = impactFixtures[0]

    @impactReport = new TuringEmailApp.Models.Reports.ImpactReport()

    @server = sinon.fakeServer.create()

    @url = "/api/v1/email_reports/impact_report"
    @server.respondWith "GET", @url, JSON.stringify(@impactFixture)

  afterEach ->
    @server.restore()

  it "has the right url", ->
    expect(@impactReport.url).toEqual @url

  describe "#fetch", ->
    beforeEach ->
      @impactReport.fetch()
      @server.respond()

    it "loads the percent sent emails replied to", ->
      validateKeys(@impactReport.toJSON(), ["percent_sent_emails_replied_to"])
