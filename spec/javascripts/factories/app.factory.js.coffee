FactoryGirl.define "App", ->
  @sequence("id", "uid")
  @name = "Test App " + @uid
  @description = "an app " + @uid
  @callback_url = "http://localhost/test" + @uid
