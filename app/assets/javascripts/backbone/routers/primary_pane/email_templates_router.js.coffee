class TuringEmailApp.Routers.EmailTemplatesRouter extends TuringEmailApp.Routers.BaseRouter
  routes:
    "email_templates/:emailTemplateCategoryUID": "showEmailTemplates"
    "email_template_categories": "showEmailTemplateCategories"

  showEmailTemplates: (emailTemplateCategoryUID) ->
    TuringEmailApp.showEmailTemplates(emailTemplateCategoryUID)

  showEmailTemplateCategories: ->
    TuringEmailApp.showEmailTemplateCategories()
