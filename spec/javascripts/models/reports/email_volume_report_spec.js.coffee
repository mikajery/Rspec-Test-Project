describe "EmailVolumeReport", ->
  beforeEach ->
    emailVolumeReportFixtures = fixture.load("reports/email_volume_report.fixture.json", true);
    @emailVolumeReportFixture = emailVolumeReportFixtures[0]

    @emailVolumeReport = new TuringEmailApp.Models.Reports.EmailVolumeReport()

    @server = sinon.fakeServer.create()

    @url = "/api/v1/email_reports/volume_report"
    @server.respondWith "GET", @url, JSON.stringify(@emailVolumeReportFixture)

  afterEach ->
    @server.restore()

  it "has the right url", ->
    expect(@emailVolumeReport.url).toEqual @url

  describe "#fetch", ->
    beforeEach ->
      @emailVolumeReport.fetch()
      @server.respond()

    it "loads the contacts report", ->
      validateKeys(@emailVolumeReport.toJSON(),
                         ["received_emails_per_month", "received_emails_per_week", "received_emails_per_day",
                          "sent_emails_per_month", "sent_emails_per_week", "sent_emails_per_day"])
