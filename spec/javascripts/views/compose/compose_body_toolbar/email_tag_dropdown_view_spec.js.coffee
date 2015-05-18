describe "EmailTagDropdownView", ->
  beforeEach ->    
    specStartTuringEmailApp()
    @emailTagDropdownView = new TuringEmailApp.Views.EmailTagDropdownView(
      composeView: TuringEmailApp.views.composeView
    )

  afterEach ->
    specStopTuringEmailApp()

  it "has the right template", ->
    expect(@emailTagDropdownView.template).toEqual JST["backbone/templates/compose/compose_body_toolbar/email_tag_dropdown"]

  describe "#render", ->
    beforeEach ->
      @emailTagDropdownView.render()      

    describe "when an email tag item link is clicked", ->

      it "appends the meta tag", ->
        @emailTagDropdownView.$el.find(".email-tag-item").first().click()        
        expect($(".tm_compose-body .redactor-editor")).toContainHtml("<meta name='email-type-tag' content='")

      it "show the success alert", ->
        spy = sinon.spy(TuringEmailApp, "showAlert")
        @emailTagDropdownView.$el.find(".email-tag-item").first().click()
        expect(spy).toHaveBeenCalled()
        spy.restore()
