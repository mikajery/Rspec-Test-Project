class TuringEmailApp.Routers.ReportsRouter extends TuringEmailApp.Routers.BaseRouter
  routes:
    "attachments_report": "showAttachmentsReport"
    "email_volume_report": "showEmailVolumeReport"
    "folders_report": "showFoldersReport"
    "geo_report": "showGeoReport"
    "impact_report": "showImpactReport"
    "inbox_efficiency_report": "showInboxEfficiencyReport"
    "lists_report": "showListsReport"
    "recommended_rules_report": "showRecommendedRulesReport"
    "summary_analytics_report": "showSummaryAnalyticsReport"
    "threads_report": "showThreadsReport"
    "top_contacts": "showTopContactsReport"
    "word_count_report": "showWordCountReport"

  showAttachmentsReport: (reportSelector) ->
    TuringEmailApp.showReport(TuringEmailApp.Models.Reports.AttachmentsReport,
                              TuringEmailApp.Views.PrimaryPane.Analytics.Reports.AttachmentsReportView)

  showEmailVolumeReport: (reportSelector) ->
    TuringEmailApp.showReport(TuringEmailApp.Models.Reports.EmailVolumeReport,
                              TuringEmailApp.Views.PrimaryPane.Analytics.Reports.EmailVolumeReportView)

  showFoldersReport: (reportSelector) ->
    TuringEmailApp.showReport(TuringEmailApp.Models.Reports.FoldersReport,
                              TuringEmailApp.Views.PrimaryPane.Analytics.Reports.FoldersReportView)

  showGeoReport: (reportSelector) ->
    TuringEmailApp.showReport(TuringEmailApp.Models.Reports.GeoReport,
                              TuringEmailApp.Views.PrimaryPane.Analytics.Reports.GeoReportView)

  showImpactReport: (reportSelector) ->
    TuringEmailApp.showReport(TuringEmailApp.Models.Reports.ImpactReport,
                              TuringEmailApp.Views.PrimaryPane.Analytics.Reports.ImpactReportView)

  showInboxEfficiencyReport: (reportSelector) ->
    TuringEmailApp.showReport(TuringEmailApp.Models.Reports.InboxEfficiencyReport,
                              TuringEmailApp.Views.PrimaryPane.Analytics.Reports.InboxEfficiencyReportView)

  showListsReport: (reportSelector) ->
    TuringEmailApp.showReport(TuringEmailApp.Models.Reports.ListsReport,
                              TuringEmailApp.Views.PrimaryPane.Analytics.Reports.ListsReportView)

  showRecommendedRulesReport: (reportSelector) ->
    TuringEmailApp.showReport(TuringEmailApp.Models.Reports.RecommendedRulesReport,
                              TuringEmailApp.Views.PrimaryPane.Analytics.Reports.RecommendedRulesReportView)

  showSummaryAnalyticsReport: (reportSelector) ->
    TuringEmailApp.showReport(TuringEmailApp.Models.Reports.SummaryAnalyticsReport,
                              TuringEmailApp.Views.PrimaryPane.Analytics.Reports.SummaryAnalyticsReportView)

  showThreadsReport: (reportSelector) ->
    TuringEmailApp.showReport(TuringEmailApp.Models.Reports.ThreadsReport,
                              TuringEmailApp.Views.PrimaryPane.Analytics.Reports.ThreadsReportView)

  showTopContactsReport: (reportSelector) ->
    TuringEmailApp.showReport(TuringEmailApp.Models.Reports.ContactsReport,
                              TuringEmailApp.Views.PrimaryPane.Analytics.Reports.ContactsReportView)

  showWordCountReport: (reportSelector) ->
    TuringEmailApp.showReport(TuringEmailApp.Models.Reports.WordCountReport,
                              TuringEmailApp.Views.PrimaryPane.Analytics.Reports.WordCountReportView)
