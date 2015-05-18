DelayedEmailsCollectionHelper = window.DelayedEmailsCollectionHelper = {}

DelayedEmailsCollectionHelper.isSortedBySendAt = (collection) ->
  if collection.length == 0
    return true

  sorted = true
  prev = collection.at(0)
  for c in [1 .. collection.length - 1]
    email = collection.at(c)

    if new Date(prev.get("send_at")).getTime() > new Date(email.get("send_at")).getTime()
      sorted = false
      break

    prev = email

  return sorted

DelayedEmailsCollectionHelper.isThisWeek = (collection) ->
  now = moment()
  endOfWeek = now.weekday(7).hour(23).minute(59).second(59)

  filtered = collection.filter (email) ->
    endOfWeek.isAfter email.get("send_at")

  return filtered.length == collection.length

DelayedEmailsCollectionHelper.isInPeriod = (collection, days) ->
  endDay = moment().add(days, 'days').hour(23).minute(59).second(59)

  filtered = collection.filter (email) ->
    endDay.isAfter email.get("send_at")

  return filtered.length == collection.length

DelayedEmailsCollectionHelper.groupedByMonth = (groups) ->
  grouped = true

  for month, group of groups
    filtered = group.filter (email) ->
      moment(email.get("send_at")).format("MMMM YYYY") == month

    if filtered.length != group.length
      grouped = false
      break

  return grouped