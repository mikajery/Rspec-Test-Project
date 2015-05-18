describe "GeoReportView", ->
  beforeEach ->
    specStartTuringEmailApp()

    @geoReport = new TuringEmailApp.Models.Reports.GeoReport()

    @geoReportView = new TuringEmailApp.Views.PrimaryPane.Analytics.Reports.GeoReportView(
      model: @geoReport
    )

    geoReportFixtures = fixture.load("reports/geo_report.fixture.json", true);
    @geoReportFixture = geoReportFixtures[0]

    @server = sinon.fakeServer.create()
    @server.respondWith "GET", new TuringEmailApp.Models.Reports.GeoReport().url, JSON.stringify(@geoReportFixture)

  afterEach ->
    @server.restore()

    specStopTuringEmailApp()

  it "has the right template", ->
    expect(@geoReportView.template).toEqual JST["backbone/templates/primary_pane/analytics/reports/geo_report"]

  describe "#render", ->
    beforeEach ->
      @renderGoogleChartSpy = sinon.spy(@geoReportView, "renderGoogleChart")
      
      @geoReport.fetch()
      @server.respond()
      
    afterEach ->
      @renderGoogleChartSpy.restore()

    it "renders the report", ->
      expect(@geoReportView.$el).toContainHtml("Geography")

    it "renders the google chart", ->
      expect(@renderGoogleChartSpy).toHaveBeenCalled()

  describe "#getGoogleChartData", ->
    beforeEach ->
      @geoReport.fetch()
      @server.respond()

      @expectedGoogleChartData = JSON.parse('{"cityStats":[["City","Number of Emails"],["",335],["New York",16],["Mountain View",20],["Manchester",66],["Chicago",27],["Houston",2],["San Antonio",5],["Indianapolis",13],["Scottsdale",6],["Ashburn",14],["San Francisco",37],["Edinburgh",9],["Atlanta",26],["San Bruno",14],["Seattle",12],["Atherton",8],["Woodbridge",1],["San Jose",2],["Dallas",4],["Stanford",4],["Leicester",1],["Lehi",1],["Menlo Park",1],["Sacramento",2],["Lansing",2],["Rancho Cucamonga",2]]}')

    it "converts the model into Google Chart data format", ->
      # TODO not sure how to test because what it renders is dependent on the current date
      #expect(@geoReportView.getGoogleChartData()).toEqual(@expectedGoogleChartData)

  describe "#renderGoogleChart", ->
    # TODO write a test for renderGoogleChart
