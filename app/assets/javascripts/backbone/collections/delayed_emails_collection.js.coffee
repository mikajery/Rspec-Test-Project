class TuringEmailApp.Collections.DelayedEmailsCollection extends TuringEmailApp.Collections.BaseCollection
  model: TuringEmailApp.Models.DelayedEmail
  url: "/api/v1/delayed_emails"

  comparator: (email) ->
    new Date(email.get("send_at")).getTime()

  # Return emails scheduled this week
  thisWeek: ->
    now = moment()
    endOfWeek = now.weekday(7).hour(23).minute(59).second(59)

    new TuringEmailApp.Collections.DelayedEmailsCollection @filter((email) ->
      endOfWeek.isAfter email.get("send_at")
    )

  filterByPeriod: (days = 0) ->
    endDay = moment().add(days, 'days').hour(23).minute(59).second(59)

    new TuringEmailApp.Collections.DelayedEmailsCollection @filter((email) ->
      endDay.isAfter email.get("send_at")
    )

  groupByMonth: ->
    @groupBy (email) ->
      moment(email.get("send_at")).format("MMMM YYYY")