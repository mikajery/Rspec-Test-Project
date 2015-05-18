class TuringEmailApp.Models.User extends Backbone.Model
  url: "/api/v1/users/current"

  validation:
    email:
      required: true
      pattern: "email"

    has_genie_report_ran:
      required: true
      acceptance: true

    profile_picture:
      required: true
      pattern: "url"

    num_emails:
      required: true
      min: 0
