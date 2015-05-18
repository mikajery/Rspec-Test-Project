describe "AttachmentsReportView", ->
  beforeEach ->
    specStartTuringEmailApp()

    @attachmentsReport = new TuringEmailApp.Models.Reports.AttachmentsReport()

    @attachmentsReportView = new TuringEmailApp.Views.PrimaryPane.Analytics.Reports.AttachmentsReportView(
      model: @attachmentsReport
    )

    attachmentsReportFixtures = fixture.load("reports/attachments_report.fixture.json", true);
    @attachmentsReportFixture = attachmentsReportFixtures[0]

    @server = sinon.fakeServer.create()
    @server.respondWith "GET", new TuringEmailApp.Models.Reports.AttachmentsReport().url, JSON.stringify(@attachmentsReportFixture)

  afterEach ->
    @server.restore()

    specStopTuringEmailApp()

  it "has the right template", ->
    expect(@attachmentsReportView.template).toEqual JST["backbone/templates/primary_pane/analytics/reports/attachments_report"]

  describe "#render", ->
    beforeEach ->
      @attachmentsReport.fetch()
      @server.respond()

    it "renders the report", ->
      expect(@attachmentsReportView.$el).toContainHtml("Attachments")
      expect(@attachmentsReportView.$el.find(".attachments-chart").length).toEqual(1)

  describe "#getChartData", ->
    beforeEach ->
      @attachmentsReport.fetch()
      @server.respond()
      
      @expectedChartData = JSON.parse('{"averageFileSize":200280,"categories":["Image","Document","PDF"],"numAttachmentsData":[14,2,2],"averageFileSizeData":[24711,1068192,561352]}')

    it "converts the model into chart data format", ->
      expect(@attachmentsReportView.getChartData()).toEqual(@expectedChartData)

  describe "#addContentTypeStatsToRunningAverage", ->
    # TODO write tests
      
  describe "#getReducedContentTypeStats", ->
    beforeEach ->
      @contentTypeStats = 
        "image/jpg": {num_attachments: 1, average_file_size: 5}
        "image/png": {num_attachments: 2, average_file_size: 10}
        "application/pdf": {num_attachments: 3, average_file_size: 13}
        "application-x/pdf": {num_attachments: 10, average_file_size: 7}
        "application/octet-stream": {num_attachments: 4, average_file_size: 7}

      @reducedContentTypeStats = @attachmentsReportView.getReducedContentTypeStats(@contentTypeStats)

    it "reduces the contentTypeStats", ->
      expect(@reducedContentTypeStats.Image.numAttachments).toEqual(3)
      expect(@reducedContentTypeStats.Image.averageFileSize).toEqual(25 / 3)

      expect(@reducedContentTypeStats.PDF.numAttachments).toEqual(13)
      expect(@reducedContentTypeStats.PDF.averageFileSize).toEqual((3*13+10*7) / 13)

      expect(@reducedContentTypeStats.Other.numAttachments).toEqual(4)
      expect(@reducedContentTypeStats.Other.averageFileSize).toEqual(7)
