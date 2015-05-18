TuringEmailApp.Views.PrimaryPane ||= {}
TuringEmailApp.Views.PrimaryPane.Analytics ||= {}
TuringEmailApp.Views.PrimaryPane.Analytics.Reports ||= {}

class TuringEmailApp.Views.PrimaryPane.Analytics.Reports.EmailVolumeReportView extends TuringEmailApp.Views.PrimaryPane.Analytics.Reports.ReportView
  template: JST["backbone/templates/primary_pane/analytics/reports/email_volume_report"]

  className: "report-view"

  render: ->
    chartData = @getChartData()

    @$el.html @template()

    @drawCharts chartData

    @

  getChartData: ->
    dailyEmailData = @getDailyEmailData(@model.get("received_emails_per_day"), @model.get("sent_emails_per_day"))
    weeklyEmailData = @getWeeklyEmailData(@model.get("received_emails_per_week"), @model.get("sent_emails_per_week"))
    monthlyEmailData = @getEmailVolumeDataPerMonth(@model.get("received_emails_per_month"),
                                                   @model.get("sent_emails_per_month"))

    [days, dailyEmailDataFormatted] = @getFormattedEmailVolumeData(dailyEmailData)
    [weeks, weeklyEmailDataFormatted] = @getFormattedEmailVolumeData(weeklyEmailData)
    [months, monthlyEmailDataFormatted] = @getFormattedEmailVolumeData(monthlyEmailData)

    data =
      dailyEmailDataFormatted: dailyEmailDataFormatted
      daysDailyEmailData: days
      weeklyEmailDataFormatted: weeklyEmailDataFormatted
      weeksDailyEmailData: weeks
      monthlyEmailDataFormatted: monthlyEmailDataFormatted
      monthsDailyEmailData: months

    return data

  getFormattedEmailVolumeData: (emailData) ->
    emailDataFormatted = []
    categories = []
    received = []
    sent = []
    for emailDatum in emailData
      categories.push emailDatum[0]
      received.push emailDatum[1]
      sent.push emailDatum[2]
    emailDataFormatted.push { name: "Received", data: received }
    emailDataFormatted.push { name: "Sent", data: sent }
    return [categories, emailDataFormatted]

  getDailyEmailData: (receivedEmailsPerDay, sentEmailsPerDay) ->
    startDate = new Date(Date.now())
    startDate.setDate(startDate.getDate() - 30) # go back one month

    stopDate = new Date(Date.now())

    @getEmailVolumeDataPerDay(receivedEmailsPerDay, sentEmailsPerDay,
                              "Day", startDate, stopDate, 1)

  getWeeklyEmailData: (receivedEmailsPerWeek, sentEmailsPerWeek) ->
    startDate = new Date(Date.now())
    startDate.setDate(startDate.getDate() - startDate.getDay() + 1) # go to start of week
    startDate.setDate(startDate.getDate() - 11 * 7) # go back 11 weeks

    stopDate = new Date(Date.now())

    @getEmailVolumeDataPerDay(receivedEmailsPerWeek, sentEmailsPerWeek,
                              "Week", startDate, stopDate, 7)

  getEmailVolumeDataPerDay: (receivedEmails, sentEmails, timePeriodLabel, startDate, stopDate, numDaysDelta) ->
    data = []

    currentDate = startDate
    while currentDate <= stopDate
      dateString = currentDate.getMonth() + 1 + "/" + currentDate.getDate() + "/" + currentDate.getFullYear()

      receivedOnThisDay = receivedEmails[dateString] ? 0
      sentOnThisDay = sentEmails[dateString] ? 0

      data.push([dateString, receivedOnThisDay, sentOnThisDay])

      currentDate.setDate(currentDate.getDate() + numDaysDelta)

    return data

  getEmailVolumeDataPerMonth: (receivedEmails, sentEmails) ->
    data = []

    startDate = new Date(Date.now())
    startDate.setMonth(startDate.getMonth() - 11)

    stopDate = new Date(Date.now())

    currentDate = startDate
    while currentDate <= stopDate
      dateString = currentDate.getMonth() + 1 + "/1/" + currentDate.getFullYear()

      receivedOnThisMonth = receivedEmails[dateString] ? 0
      sentOnThisMonth = sentEmails[dateString] ? 0

      data.push([dateString, receivedOnThisMonth, sentOnThisMonth])

      currentDate.setMonth(currentDate.getMonth() + 1)

    return data

  drawCharts: (chartData) ->
    @drawChart chartData.daysDailyEmailData, chartData.dailyEmailDataFormatted, ".emails-per-day-chart", "Daily Email Volume"
    @drawChart chartData.weeksDailyEmailData, chartData.weeklyEmailDataFormatted, ".emails-per-week-chart", "Weekly Email Volume"
    @drawChart chartData.monthsDailyEmailData, chartData.monthlyEmailDataFormatted, ".emails-per-month-chart", "Monthly Email Volume"

  drawChart: (categories, data, divSelector, chartTitle) ->
    return if $(divSelector).length is 0

    @$el.find(divSelector).highcharts
      chart:
        type: 'area'
        style: fontFamily: "'Gotham SSm A', 'Gotham SSm B', 'Helvetica Neue', Helvetica, Arial, sans-serif", fontSize: "12px", fontWeight: "300"
      title: text: chartTitle
      credits: enabled: false
      xAxis:
        categories: categories
        title: text: null
        labels:
          enabled: true, y: 20, rotation: -45, align: 'right'
      yAxis:
        title: text: 'Emails'
        labels: formatter: ->
          @value
      tooltip:
        shadow: false
        pointFormat: '{series.name}: <b>{point.y:,.0f}</b>'
      plotOptions: area:
        marker:
          radius: 2
          enabled: false
          symbol: 'circle'
          states: hover: enabled: true
      series: data
