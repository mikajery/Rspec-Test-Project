describe "AttachmentsReport", ->
  beforeEach ->
    attachmentsReportFixtures = fixture.load("reports/attachments_report.fixture.json", true);
    @attachmentsReportFixture = attachmentsReportFixtures[0]

    @attachmentsReport = new TuringEmailApp.Models.Reports.AttachmentsReport()

    @server = sinon.fakeServer.create()

    @url = "/api/v1/email_reports/attachments_report"
    @server.respondWith "GET", @url, JSON.stringify(@attachmentsReportFixture)

  afterEach ->
    @server.restore()

  it "has the right url", ->
    expect(@attachmentsReport.url).toEqual @url

  describe "#fetch", ->
    beforeEach ->
      @attachmentsReport.fetch()
      @server.respond()

    it "loads the attachments report", ->
      validateKeys(@attachmentsReport.toJSON(), ["average_file_size", "content_type_stats"])
