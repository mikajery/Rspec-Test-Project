TuringEmailApp.Views.PrimaryPane ||= {}
TuringEmailApp.Views.PrimaryPane.Settings ||= {}

class TuringEmailApp.Views.PrimaryPane.Settings.SettingsView extends TuringEmailApp.Views.BaseView
  template: JST["backbone/templates/primary_pane/settings/settings"]

  events:
    "click .uninstall-app-button": "uninstallApp"

  className: "tm_content tm_settings-view"

  initialize: (options) ->
    super(options)

    @listenTo(@model, "change", @render)
    @listenTo(@model, "destroy", @remove)

  render: ->
    selectedTabID = $(".tm_content-tab-pane.active").attr("id")

    @$el.html(@template({
      userConfiguration: @model.toJSON()
    }))

    @setupSwitches()
    @setupProfilePane()

    $("a[href=#" + selectedTabID + "]").click() if selectedTabID?

    @

  setupSwitches: ->
    @$(".keyboard-shortcuts-switch").bootstrapSwitch()
    @$(".genie-switch").bootstrapSwitch()
    @$(".auto-cleaner-switch").bootstrapSwitch()
    @$(".developer-switch").bootstrapSwitch()
    @$(".inbox-tabs-switch").bootstrapSwitch()

    @$(".keyboard-shortcuts-switch, .genie-switch, .auto-cleaner-switch, .developer-switch, .inbox-tabs-switch").
         on("switch-change", (evt, state) =>
      @saveSettings()
    )

    @$(".split-pane-select").change(=>
      @saveSettings()
      split_pane_mode = @$(".split-pane-select").val()
      if TuringEmailApp.views.mainView.splitPaneLayout?
        TuringEmailApp.views.mainView.splitPaneLayout.state.south.size = 0.5 if split_pane_mode is "horizontal"
        TuringEmailApp.views.mainView.splitPaneLayout.state.east.size = 0.75 if split_pane_mode is "vertical"
    )

  uninstallApp: (evt) ->
    appID = $(evt.currentTarget).attr("data")
    @trigger("uninstallAppClicked", this, appID)

    $(evt.currentTarget).parent().parent().remove()

  saveSettings: (refresh=false) ->
    keyboard_shortcuts_enabled = @$(".keyboard-shortcuts-switch").parent().parent().hasClass("switch-on")
    genie_enabled = @$(".genie-switch").parent().parent().hasClass("switch-on")
    split_pane_mode = @$(".split-pane-select").val()
    auto_cleaner_enabled = @$(".auto-cleaner-switch").parent().parent().hasClass("switch-on")
    developer_enabled = @$(".developer-switch").parent().parent().hasClass("switch-on")
    inbox_tabs_enabled = @$(".inbox-tabs-switch").parent().parent().hasClass("switch-on")

    @model.set({
      genie_enabled: genie_enabled,
      split_pane_mode: split_pane_mode,
      keyboard_shortcuts_enabled: keyboard_shortcuts_enabled,
      auto_cleaner_enabled: auto_cleaner_enabled,
      developer_enabled: developer_enabled,
      inbox_tabs_enabled: inbox_tabs_enabled
    })

    @model.save(null, {
      patch: true
      success: (model, response) ->
        location.reload() if refresh
        TuringEmailApp.showAlert("You have successfully saved your settings!", "alert-success", 5000)
      }
    )

  setupProfilePane: ->
    @$(".update-profile-button").click =>
      user = TuringEmailApp.models.user
      user.url = "/api/v1/users/update"
      name = @$(".tm_input.name-input").val()

      user.set({
        name: name
      })

      user.save(null, {
        patch: true
        type: "PATCH"
        success: (model, response) ->
          TuringEmailApp.showAlert("You have successfully updated your user profile!", "alert-success", 5000)
          TuringEmailApp.views.toolbarView.render()
        }
      )

      return
