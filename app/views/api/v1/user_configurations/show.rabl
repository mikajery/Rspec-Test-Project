object @user_configuration

node(:id) do |user_configuration|
  "id"
end

attributes :demo_mode_enabled, :genie_enabled, :split_pane_mode,
           :keyboard_shortcuts_enabled, :developer_enabled,
           :email_lis_view_row_height,
           :auto_cleaner_enabled

node(:installed_apps) do |user_configuration|
  partial('api/v1/installed_apps/index', :object => user_configuration.user.installed_apps)
end

node(:skin_uid) do |user_configuration|
  user_configuration.skin.uid if user_configuration.skin
end

node(:email_signature_uid) do |user_configuration|
  user_configuration.email_signature.uid if user_configuration.email_signature
end
