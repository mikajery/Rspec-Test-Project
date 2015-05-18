class TuringEmailApp.Models.UserConfiguration extends Backbone.Model
  @EmailThreadsPerPage: 30

  url: "/api/v1/user_configurations"

  validation:
    demo_mode_enabled:
      required: true
      acceptance: true

    genie_enabled:
      required: true
      acceptance: true

    split_pane_mode:
      required: true

    keyboard_shortcuts_enabled:
      required: true
      acceptance: true

    developer_enabled:
      required: true
      acceptance: true

    auto_cleaner_enabled:
      required: true
      acceptance: true

    id:
      required: true

    installed_apps:
      required: true
      isArray: true
