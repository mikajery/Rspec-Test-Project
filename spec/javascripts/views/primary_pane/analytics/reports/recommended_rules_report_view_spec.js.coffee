describe "RecommendedRulesReportView", ->
  beforeEach ->
    specStartTuringEmailApp()

    @recommendedRulesReport = new TuringEmailApp.Models.Reports.RecommendedRulesReport()

    @recommendedRulesReportView = new TuringEmailApp.Views.PrimaryPane.Analytics.Reports.RecommendedRulesReportView(
      model: @recommendedRulesReport
    )

    recommendedRulesReportFixtures = fixture.load("reports/recommended_rules_report.fixture.json", true);
    @recommendedRulesReportFixture = recommendedRulesReportFixtures[0]

    @server = sinon.fakeServer.create()
    @server.respondWith "GET", new TuringEmailApp.Models.Reports.RecommendedRulesReport().url, JSON.stringify(@recommendedRulesReportFixture)

  afterEach ->
    @server.restore()

    specStopTuringEmailApp()

  it "has the right template", ->
    expect(@recommendedRulesReportView.template).toEqual JST["backbone/templates/primary_pane/analytics/reports/recommended_rules_report"]

  describe "#render", ->
    beforeEach ->
      @recommendedRulesReport.fetch()
      @server.respond()

    it "renders the report", ->
      expect(@recommendedRulesReportView.$el).toContainHtml("Recommended Rules")

    it "renders the genie rule explanation text", ->
      expect(@recommendedRulesReportView.$el).toContainHtml("<p>The genie has been working extra hard to keep your inbox clean, and recommends that you make the following rules so that these emails skip your inbox during the day:</p>")

    it "renders the email rules", ->
      expect(@recommendedRulesReportView.$el).toContainHtml('Rule: filter emails from ' + @recommendedRulesReport.get("rules_recommended")[0].list_id + " into " + @recommendedRulesReport.get("rules_recommended")[0].destination_folder + '.')
      expect(@recommendedRulesReportView.$el).toContainHtml('<a data-prevent-default="" class="rule_recommendation_link" href="' + @recommendedRulesReport.get("rules_recommended")[0].list_id + '">Create rule.</a>')

    it "sets up the recommended rules links", ->
      spy = sinon.spy(@recommendedRulesReportView, "setupRecommendedRulesLinks")
      @recommendedRulesReportView.render()
      expect(spy).toHaveBeenCalled()
      spy.restore()

  describe "#setupRecommendedRulesLinks", ->
    beforeEach ->
      @recommendedRulesReport.fetch()
      @server.respond()

    it "hooks the click action on the rules recommendation link", ->
      expect(@recommendedRulesReportView.$el.find(".rule_recommendation_link")).toHandle("click")

    describe "when the rules recommendation link is clicked", ->
      it "prevents the default link action", ->
        selector = ".rule_recommendation_link"
        $("body").append(@recommendedRulesReportView.$el)
        clickSpy = spyOnEvent(selector, "click")
        
        @recommendedRulesReportView.$el.find(selector).click()

        expect(clickSpy).toHaveBeenPrevented()

        @recommendedRulesReportView.$el.remove()

      it "shows the success alert", ->
        @recommendedRulesReportView.$el.find(".rule_recommendation_link").click()
        expect(@recommendedRulesReportView.$el).toContainHtml('<br />
                              <div class="col-md-4 alert alert-success" role="alert">
                                You have successfully created an email rule!
                              </div>')

      it "hides the rule recommendation link", ->
        @recommendedRulesReportView.$el.find(".rule_recommendation_link").click()
        expect(@recommendedRulesReportView.$el).not.toContainHtml('<a data-prevent-default="" class="rule_recommendation_link" href="' + @recommendedRulesReport.get("rules_recommended")[0].list_id + '">Create rule.</a>')

      it "should post the email rule to the server", ->
        @recommendedRulesReportView.$el.find(".rule_recommendation_link").click()
        
        expect(@server.requests.length).toEqual 2
        request = @server.requests[1]
        expect(request.method).toEqual "POST"
        expect(request.url).toEqual "/api/v1/email_rules"
