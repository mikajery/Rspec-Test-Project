TuringEmailApp.Views.PrimaryPane ||= {}

class TuringEmailApp.Views.PrimaryPane.ScheduleEmailsView extends TuringEmailApp.Views.CollectionView
  template: JST["backbone/templates/primary_pane/schedule_emails"]

  className: "tm_content tm_content-with-toolbar"

  events:
    "click .new-delayed-email-button": "onNewDelayedEmailClick"
    "click .delete-delayed-email-button": "onDeleteDelayedEmailClick"
    "click .edit-delayed-email-button": "onEditDelayedEmailClick"
    "click .send-delayed-email-button": "onSendDelayedEmailClick"
    "click .period-dropdown .dropdown-menu a": "onPeriodFilterClick"
    "click .email-collapse-expand": "onEmailExpandAndCollapse"
    "click .month-collapse-expand": "onMonthExpandAndCollapse"

  periodFilter: -1

  render: ->
    @filteredCollection = if @periodFilter == -1 then @collection else @collection.filterByPeriod(@periodFilter)
    groupedCollection = @filteredCollection.groupByMonth()

    @$el.html @template(
      total: @filteredCollection.length
      weekTotal: @filteredCollection.thisWeek().length
      delayedEmails: groupedCollection
    )

    @$(".datetimepicker").datetimepicker
      format: TuringEmailApp.Views.ComposeView.dateFormat
      formatTime: "g:i a"
      onShow: (dp, $input) ->
        $('.new-delayed-email-button').prop('disabled', false)

    @

  onPeriodFilterClick: (evt) ->
    @periodFilter = $(evt.target).data("days")
    @render()
    @$(".period-dropdown-menu").text($(evt.target).text())

  onNewDelayedEmailClick: (evt) ->
    sendLateDateTime = @$(".datetimepicker").val()
    TuringEmailApp.views.mainView.composeWithSendLaterDatetime(sendLateDateTime)

  onDeleteDelayedEmailClick: (evt) ->
    uid = $(evt.target).closest(".tm_email").data("uid")
    email = @collection.get uid

    email.destroy().then ->
      console.log 'Deleted scheduled email successfully'

  onEditDelayedEmailClick: (evt) ->
    uid = $(evt.target).closest(".tm_email").data("uid")
    delayedEmail = @collection.get uid

    TuringEmailApp.views.mainView.loadEmailDelayed delayedEmail

  onSendDelayedEmailClick: (evt) ->
    uid = $(evt.target).closest(".tm_email").data("uid")
    delayedEmail = @collection.get uid

    TuringEmailApp.views.mainView.composeView.loadEmailDelayed delayedEmail
    TuringEmailApp.views.mainView.composeView.sendEmail()

  onMonthExpandAndCollapse: (evt) ->
    if $(evt.currentTarget).hasClass("tm_month-collapsed")
      emailMonth = $(evt.currentTarget).removeClass("tm_month-collapsed")
      emailMonth.next().children('.tm_email').removeClass("tm_email-collapsed")
    else
      emailMonth = $(evt.currentTarget).addClass("tm_month-collapsed")
      emailMonth.next().children('.tm_email').addClass("tm_email-collapsed")

  onEmailExpandAndCollapse: (evt) ->
    emailHeader = $(evt.currentTarget).parent()
    emailHeader.parent().toggleClass("tm_email-collapsed")
