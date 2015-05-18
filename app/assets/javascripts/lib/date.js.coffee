class @TDate

  constructor: (date) ->
    @date = date

  initializeWithISO8601: (iSO8601DateString) ->
    @date = new Date(iSO8601DateString)
    @

  longFormDateString: ->
    dateStringComponents = @date.toDateString().split(" ")
    dayString = dateStringComponents[0]
    monthString = dateStringComponents[1]
    dateNumberString = dateStringComponents[2]
    yearString = dateStringComponents[3]
    localeStringTime = @date.toLocaleTimeString(navigator.language, {hour: "2-digit", minute: "2-digit"})

    return dayString + ", " + monthString + " " + dateNumberString + ", " + yearString + " at " + localeStringTime
