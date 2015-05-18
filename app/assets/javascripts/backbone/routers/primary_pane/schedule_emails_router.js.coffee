class TuringEmailApp.Routers.ScheduleEmailsRouter extends TuringEmailApp.Routers.BaseRouter
  routes:
    "schedule_emails": "showScheduleEmails"

  showScheduleEmails: ->
    TuringEmailApp.showScheduleEmails()
