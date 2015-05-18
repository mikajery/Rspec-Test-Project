describe "ThreadsReport", ->
  beforeEach ->
    threadsFixtures = fixture.load("reports/threads_report.fixture.json", true);
    @threadsFixture = threadsFixtures[0]

    @threadssReport = new TuringEmailApp.Models.Reports.ThreadsReport()

    @server = sinon.fakeServer.create()

    @url = "/api/v1/email_reports/threads_report"
    @server.respondWith "GET", @url, JSON.stringify(@threadsFixture)

  afterEach ->
    @server.restore()

  it "has the right url", ->
    expect(@threadssReport.url).toEqual @url

  describe "#fetch", ->
    beforeEach ->
      @threadssReport.fetch()
      @server.respond()

    it "loads the contacts report", ->
      validateKeys(@threadssReport.toJSON(), ["average_thread_length", "top_email_threads"])
