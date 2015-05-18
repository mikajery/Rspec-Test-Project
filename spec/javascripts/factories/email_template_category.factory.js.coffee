FactoryGirl.define "EmailTemplateCategory", ->
  @sequence("id", "uid")

  @name = "Email template category" + @uid

  @created_at = new Date()