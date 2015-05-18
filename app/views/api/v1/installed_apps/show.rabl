object @installed_app

attributes :permissions_email_headers, :permissions_email_content, :installed_app_subclass_type

node(:app) do |installed_app|
  partial('api/v1/apps/show', :object => installed_app.app)
end

child(:installed_app_subclass, :if => lambda { |installed_app| installed_app.installed_app_subclass_type == 'InstalledPanelApp' }) do |installed_app_subclass|
  extends('api/v1/installed_panel_apps/show')
end
