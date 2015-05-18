TuringEmailApp.Views.PrimaryPane ||= {}
TuringEmailApp.Views.PrimaryPane.EmailTemplates ||= {}

class TuringEmailApp.Views.PrimaryPane.EmailTemplates.EmailTemplatesView extends TuringEmailApp.Views.RactiveView
  template: JST["backbone/templates/primary_pane/email_templates/email_templates"]
  className: "tm_content tm_content-with-toolbar"

  events:
    "click .create-email-template-button": "showCreateEmailTemplateDialog"
    "click .edit-email-template-button": "showEditEmailTemplateDialog"
    "click .move-email-template-button": "showMoveEmailTemplateDialog"
    "click .delete-email-template-button": "onDeleteEmailTemplateClick"

  initialize: (options) ->
    super(options)

    @app = TuringEmailApp
    @categoriesCollection = @app.collections.emailTemplateCategories
    @categoryUID = options.categoryUID
    @categoryTitle = if @categoryUID then @app.collections.emailTemplateCategories.get(@categoryUID).get("name") else "All Templates"

    @listenTo @app.collections.emailTemplates, 'add', @render
    @listenTo @app.collections.emailTemplates, 'change', @render
    @listenTo @app.collections.emailTemplates, 'destroy', @render

  data: -> _.extend {}, super(),
    "dynamic":
      "emailTemplates": @collection
      "categories": @categoriesCollection
      "categoryTitle": @categoryTitle
      "formatCreatedAt": (i) ->
        dt = @get "emailTemplates.#{i}"
        moment(dt.get('created-at')).format("MM/DD/YYYY")

  render: ->
    console.log "emailTemplatesView render"
    @collection = if not @categoryUID then @app.collections.emailTemplates else
      @app.collections.emailTemplates.filter((emailTemplate) =>
        emailTemplate.get("category_uid") == @categoryUID
      )

    super()

    @setupEmailExpandAndCollapse()
    @setupMoveEmailTemplateDialog()

    @

  setupDialog: (selector, options) ->
    dialogOptions =
      "autoOpen": false
      "width": 400
      "modal": true
      "resizable": false

    @$(selector).dialog(_.extend(dialogOptions, options))

  setupEmailExpandAndCollapse: ->
    @$(".email-collapse-expand").click (evt) ->
      emailHeader = $(evt.currentTarget).parent()
      email = emailHeader.parent()
      email.toggleClass("tm_email-collapsed")

  ##############
  ### Create ###
  ##############

  showCreateEmailTemplateDialog: ->
    @app.views.mainView.templateComposeView.loadEmpty @categoryUID
    @app.views.mainView.templateComposeView.show()

  ############
  ### Edit ###
  ############

  showEditEmailTemplateDialog: (evt) ->
    uid = $(evt.target).closest("[data-uid]").data("uid")
    emailTemplate = @app.collections.emailTemplates.get uid

    @app.views.mainView.templateComposeView.loadEmailTemplate emailTemplate, @categoryUID
    @app.views.mainView.templateComposeView.show()

  ############
  ### Move ###
  ############

  setupMoveEmailTemplateDialog: ->
    @moveEmailTemplateDialog =
      @setupDialog ".move-email-template-dialog-form",
        "dialogClass": ".move-email-template-dialog"
        "buttons": [{
          "text": "Cancel"
          "class": "tm_button"
          "click": => @moveEmailTemplateDialog.dialog "close"
        }, {
          "text": "Move"
          "class": "tm_button tm_button-blue"
          "click": => @moveEmailTemplate()
        }]

  moveEmailTemplate: ->
    categoryUID = @ractive.get "selectedCategoryUID"

    @moveEmailTemplateDialog.dialog "close"

    @selectedEmailTemplate.set
      "category_uid": categoryUID

    @selectedEmailTemplate.save null,
      patch: true
      success: (model, response) =>
        @showSuccessOfMoveEmailTemplate()
        @categoriesCollection.fetch()

  showMoveEmailTemplateDialog: (evt) ->
    uid = $(evt.target).closest("[data-uid]").data("uid")
    @selectedEmailTemplate = @app.collections.emailTemplates.get uid
    selectedCategoryUID = if @selectedEmailTemplate.get("category_uid")? then @selectedEmailTemplate.get("category_uid") else ""

    @ractive.set
      "selectedCategoryUID": selectedCategoryUID

    @moveEmailTemplateDialog.dialog("open")

  showSuccessOfMoveEmailTemplate: ->
    TuringEmailApp.showAlert("Email template has been moved successfully!",
      "alert-success",
      3000)

  ##############
  ### Delete ###
  ##############

  onDeleteEmailTemplateClick: (evt) ->
    uid = $(evt.target).closest("[data-uid]").data("uid")
    emailTemplate = @app.collections.emailTemplates.get uid

    emailTemplate.destroy().then =>
      @app.showAlert("Deleted email template successfully!",
        "alert-success", 3000
      )
