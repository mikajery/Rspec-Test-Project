describe "FoldersReport", ->
  beforeEach ->
    foldersFixtures = fixture.load("reports/folders_report.fixture.json", true);
    @foldersFixture = foldersFixtures[0]

    @foldersReport = new TuringEmailApp.Models.Reports.FoldersReport()

    @server = sinon.fakeServer.create()

    @url = "/api/v1/email_reports/folders_report"
    @server.respondWith "GET", @url, JSON.stringify(@foldersFixture)

  afterEach ->
    @server.restore()

  it "has the right url", ->
    expect(@foldersReport.url).toEqual @url

  describe "#fetch", ->
    beforeEach ->
      @foldersReport.fetch()
      @server.respond()

    it "loads the correct attributes", ->
      validateKeys(@foldersReport.toJSON(), ["percent_draft", "percent_inbox", "percent_sent", "percent_spam", "percent_starred", "percent_trash", "percent_unread"])
