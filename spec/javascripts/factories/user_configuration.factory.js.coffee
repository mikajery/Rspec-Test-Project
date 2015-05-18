FactoryGirl.define "UserConfiguration", ->
  @sequence("id", "id");
  @demo_mode_enabled = false
  @keyboard_shortcuts_enabled = true
  @genie_enabled = true
  @split_pane_mode = "horizontal"
  @auto_cleaner_enabled = false
  @developer_enabled = false
  @inbox_tabs_enabled = false

  @installed_apps = FactoryGirl.createLists("InstalledPanelApp", FactoryGirl.SMALL_LIST_SIZE)
