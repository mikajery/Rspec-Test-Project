FactoryGirl.define "InstalledPanelApp", inherit: "InstalledApp", ->
  @installed_app_subclass_type = "InstalledPanelApp"

  @app = FactoryGirl.create("App")
  
  @panel = "right"
  @position = 0
