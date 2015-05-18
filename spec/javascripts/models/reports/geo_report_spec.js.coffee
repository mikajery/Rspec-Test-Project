describe "GeoReport", ->
  beforeEach ->
    geoReportFixtures = fixture.load("reports/geo_report.fixture.json", true);
    @geoReportFixture = geoReportFixtures[0]

    @geoReport = new TuringEmailApp.Models.Reports.GeoReport()

    @server = sinon.fakeServer.create()

    @url = "/api/v1/email_reports/ip_stats_report"
    @server.respondWith "GET", @url, JSON.stringify(@geoReportFixture)

  afterEach ->
    @server.restore()

  it "has the right url", ->
    expect(@geoReport.url).toEqual @url

  describe "#fetch", ->
    beforeEach ->
      @geoReport.fetch()
      @server.respond()

    it "loads the contacts report", ->
      validateKeys(@geoReport.toJSON(), ["ip_stats"])
