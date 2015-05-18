TuringEmailApp.Views.PrimaryPane ||= {}

class TuringEmailApp.Views.PrimaryPane.EmailTrackersView extends TuringEmailApp.Views.CollectionView
  template: JST["backbone/templates/primary_pane/email_trackers"]
  className: "tm_content"

  render: ->
    @$el.html(@template(emailTrackers: @collection.toJSON()))

    chartData = @formatChartData @collection.toJSON()

    @drawChart chartData

    @

  formatChartData: (emailTrackersJSON) ->
    months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
    sent = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    opens = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

    # Calculate sent and opens
    for emailTracker in emailTrackersJSON
      emailDate = new Date(emailTracker["email_date"])
      sent[emailDate.getMonth()] += 1
      for emailTrackerRecipient in emailTracker["email_tracker_recipients"]
        for emailTrackerView in emailTrackerRecipient["email_tracker_views"]
          emailOpenDate = new Date(emailTrackerView["created_at"])
          opens[emailOpenDate.getMonth()] += 1

    chartData =
      months: months
      sent: sent
      opens: opens

  drawChart: (chartData) ->
    @$el.find('.email-tracker-chart').highcharts
      chart:
        type: 'column'
        backgroundColor: null
        style: fontFamily: "'Gotham SSm A', 'Gotham SSm B', 'Helvetica Neue', Helvetica, Arial, sans-serif", fontSize: "12px", fontWeight: "300"
      title: text: 'Emails Sent & Opened by month'
      credits: enabled: false
      exporting: enabled: false
      tooltip:
        shadow: false
      plotOptions: bar: dataLabels: enabled: true
      xAxis:
        title: text: null
        categories: chartData.months
      yAxis: [{
        min: 0
        title: text: null
      }, {
        min: 0
        opposite: true
        title: text: null
      }]
      series: [{
        yAxis: 0
        name: 'Sent'
        data: chartData.sent
      }, {
        yAxis: 0
        name: 'Opens'
        data: chartData.opens
      }]
