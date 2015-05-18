TuringEmailApp.Views.PrimaryPane ||= {}
TuringEmailApp.Views.PrimaryPane.EmailTemplates ||= {}

class TuringEmailApp.Views.PrimaryPane.EmailTemplates.EmailTemplateCategoriesView extends TuringEmailApp.Views.RactiveView
  template: JST["backbone/templates/primary_pane/email_templates/email_template_categories"]
  className: "tm_content tm_content-with-toolbar"

  events:
    "click .create-email-template-category-button": "showCreateEmailTemplateCategoryDialog"
    "click .update-email-template-category-button": "showUpdateEmailTemplateCategoryDialog"
    "click .delete-email-template-category-button": "deleteEmailTemplateCategory"


  data: -> _.extend {}, super(),
    "dynamic":
      "emailTemplateCategories": @collection
      "emailTemplates": @templatesCollection
      "formatCreatedAt": (i) ->
        dt = @get "emailTemplateCategories.#{i}"
        moment(dt.get('created-at')).format("MM/DD/YYYY")


  initialize: (options) ->
    super(options)

    @templatesCollection = options.templatesCollection

  render: ->
    super()

    @setupCreateEmailTemplateCategoryDialog()
    @setupUpdateEmailTemplateCategoryDialog()

    @


  setupDialog: (selector, options) ->
    dialogOptions =
      "autoOpen": false
      "width": 400
      "modal": true
      "resizable": false

    @$(selector).dialog(_.extend(dialogOptions, options))

  ##############
  ### Create ###
  ##############

  setupCreateEmailTemplateCategoryDialog: ->
    @createEmailTemplateCategoryDialog =
      @setupDialog ".create-email-template-category-dialog-form",
        "dialogClass": "create-email-template-category-dialog"
        "buttons": [{
          "text": "Cancel"
          "class": "tm_button"
          "click": => @createEmailTemplateCategoryDialog.dialog "close"
        }, {
          "text": "Create"
          "class": "tm_button tm_button-blue"
          "click": => @createEmailTemplateCategory()
        }]


  createEmailTemplateCategory: ->
    newName = @ractive.get "newName"
    @ractive.set "newName", ""

    # Check if name is empty
    if newName == ""
      TuringEmailApp.showAlert("Please enter a category name", null, 5000)
      return

    # Check if name already exists
    if @collection.findWhere({name: newName})?
      TuringEmailApp.showAlert("Category with this name already exists", null, 5000)
      return

    # Create new category
    newEmailTemplateCategory = new TuringEmailApp.Models.EmailTemplateCategory
      name: newName

    newEmailTemplateCategory.save null,
      "success": =>
        @showSuccessOfCreateEmailTemplateCategory()


  showCreateEmailTemplateCategoryDialog: ->
    @ractive.set "newName", ""
    @createEmailTemplateCategoryDialog.dialog("open")


  showSuccessOfCreateEmailTemplateCategory: ->
    TuringEmailApp.showAlert("Category has been successfully created!", "alert-success", 3000)

    @createEmailTemplateCategoryDialog.dialog "close"

    @collection.fetch()


  ##############
  ### Update ###
  ##############


  setupUpdateEmailTemplateCategoryDialog: ->
    @updateEmailTemplateCategoryDialog =
      @setupDialog ".update-email-template-category-dialog-form",
        "dialogClass": "update-email-template-category-dialog"
        "buttons": [{
          "text": "Cancel"
          "class": "tm_button"
          "click": => @updateEmailTemplateCategoryDialog.dialog "close"
        }, {
          "text": "Update"
          "type": "submit"
          "class": "tm_button tm_button-blue"
          "click": => @updateEmailTemplateCategory()
        }]


  updateEmailTemplateCategory: (evt) ->
    newName = @ractive.get "newName"

    # Check if newName is empty
    if newName == ""
      TuringEmailApp.showAlert("Please enter a new category name", null, 5000)
      return

    # Check if name has not changed
    if newName == @selectedEmailTemplateCategory.get('name')
      TuringEmailApp.showAlert("Category name left unchanged", "alert-success", 3000)
      @updateEmailTemplateCategoryDialog.dialog "close"
      return

    # Check if new name already exists
    if @collection.findWhere({name: newName})?
      TuringEmailApp.showAlert("Category with this name already exists", null, 5000)
      return

    @selectedEmailTemplateCategory.set 'name', newName
    @selectedEmailTemplateCategory.save null,
      patch: true
      success: (model, response) =>
        @showSuccessOfUpdateEmailTemplateCategory()


  showUpdateEmailTemplateCategoryDialog: (evt) ->
    uid = $(evt.currentTarget).closest('[data-uid]').data("uid")
    @selectedEmailTemplateCategory = @collection.get(uid)

    # Set the current selected email template category name
    @ractive.set "newName": @selectedEmailTemplateCategory.get('name')

    @updateEmailTemplateCategoryDialog.dialog "open"


  showSuccessOfUpdateEmailTemplateCategory: ->
    TuringEmailApp.showAlert("Category has been successfully updated!", "alert-success", 3000)

    @updateEmailTemplateCategoryDialog.dialog "close"


  ##############
  ### Delete ###
  ##############


  deleteEmailTemplateCategory: (evt) ->
    uid = $(evt.currentTarget).closest('[data-uid]').data("uid")
    emailTemplateCategory = @collection.get(uid)
    emailTemplateCategory.destroy()
    TuringEmailApp.showAlert("Category has been successfully deleted!", "alert-success", 3000)
