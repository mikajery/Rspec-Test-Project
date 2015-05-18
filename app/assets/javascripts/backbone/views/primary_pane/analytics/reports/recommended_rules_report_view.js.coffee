TuringEmailApp.Views.PrimaryPane ||= {}
TuringEmailApp.Views.PrimaryPane.Analytics ||= {}
TuringEmailApp.Views.PrimaryPane.Analytics.Reports ||= {}

class TuringEmailApp.Views.PrimaryPane.Analytics.Reports.RecommendedRulesReportView extends  TuringEmailApp.Views.PrimaryPane.Analytics.Reports.ReportView
  template: JST["backbone/templates/primary_pane/analytics/reports/recommended_rules_report"]

  className: "report-view"

  render: ->
    modelJSON = @model.toJSON()
    @$el.html(@template(modelJSON))
    
    @setupRecommendedRulesLinks()

    @

  setupRecommendedRulesLinks: ->
    @$(".rule_recommendation_link").click (evt) ->
      $(@).parent().append('<br />
                            <div class="col-md-4 alert alert-success" role="alert">
                              You have successfully created an email rule!
                            </div>')
      $(@).hide()
      $.post "/api/v1/email_rules", { list_id: $(@).attr("href"), destination_folder: $(@).text() }
