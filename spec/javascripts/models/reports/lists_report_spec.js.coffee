describe "ListsReport", ->
  beforeEach ->
    listsFixtures = fixture.load("reports/lists_report.fixture.json", true);
    @listsFixture = listsFixtures[0]

    @listsReport = new TuringEmailApp.Models.Reports.ListsReport()

    @server = sinon.fakeServer.create()

    @url = "/api/v1/email_reports/lists_report"
    @server.respondWith "GET", @url, JSON.stringify(@listsFixture)

  afterEach ->
    @server.restore()

  it "has the right url", ->
    # currently using fake data
    #expect(@listsReport.url).toEqual @url

  describe "#fetch", ->
    beforeEach ->
      @listsReport.fetch()
      @server.respond()

    it "loads the contacts report", ->
      validateKeys(@listsReport.toJSON(), ["lists_email_daily_average", "emails_per_list",
                                                 "email_threads_per_list", "email_threads_replied_to_per_list",
                                                 "sent_emails_per_list", "sent_emails_replied_to_per_list"])
