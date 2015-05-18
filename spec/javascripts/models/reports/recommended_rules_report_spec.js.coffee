describe "RecommendedRulesReport", ->
  beforeEach ->
    recommendedRulesFixtures = fixture.load("reports/recommended_rules_report.fixture.json", true);
    @recommendedRulesFixture = recommendedRulesFixtures[0]

    @recommendedRulesReport = new TuringEmailApp.Models.Reports.RecommendedRulesReport()

    @server = sinon.fakeServer.create()

    @url = "/api/v1/email_rules/recommended_rules"
    @server.respondWith "GET", @url, JSON.stringify(@recommendedRulesFixture)

  afterEach ->
    @server.restore()

  it "has the right url", ->
    expect(@recommendedRulesReport.url).toEqual @url

  describe "#fetch", ->
    beforeEach ->
      @recommendedRulesReport.fetch()
      @server.respond()

    it "loads the contacts report", ->
      validateKeys(@recommendedRulesReport.toJSON(), ["rules_recommended"])
