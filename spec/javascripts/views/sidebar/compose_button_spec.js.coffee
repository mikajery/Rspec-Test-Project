describe "ComposeButtonView", ->
  beforeEach ->
    specStartTuringEmailApp()

    @composeButtonView = new TuringEmailApp.Views.ComposeButtonView()

  afterEach ->
    specStopTuringEmailApp()

  it "has the right template", ->
    expect(@composeButtonView.template).toEqual JST["backbone/templates/sidebar/compose_button"]

  it "has the right event", ->
    expect(@composeButtonView.events["click .quick-compose-item"]).toEqual "quickCompose"

  describe "#render", ->
    beforeEach ->
      @composeButtonView.render()      

    describe "when a quick compose item is clicked", ->

      # TODO fix this test.
      # it "adds text to the body", ->
      #   firstQuickCompose = @composeButtonView.$el.find(".quick-compose-item").first()
      #   quickComposeText = firstQuickCompose.text().replace("Quick Compose: ", "")
      #   firstQuickCompose.click()
      #   expect($(".compose-form iframe.cke_wysiwyg_frame.cke_reset").contents().find("body.cke_editable")).toContainText(quickComposeText)

      it "adds text to the subject-input", ->
        firstQuickCompose = @composeButtonView.$el.find(".quick-compose-item").first()
        quickComposeText = firstQuickCompose.text().replace("Quick Compose: ", "")
        firstQuickCompose.click()
        expect($(".compose-modal .subject-input").val()).toEqual(quickComposeText)
