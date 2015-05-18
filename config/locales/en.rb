# Files in the config/locales directory are used for internationalization
# and are automatically loaded by Rails. If you want to use locales other
# than English, add the necessary files in this directory.
#
# To use the locales, use `I18n.t`:
#
#     I18n.t 'hello'
#
# In views, this is aliased to just `t`:
#
#     <%= t('hello') %>
#
# To use a different locale, set it with `I18n.locale`:
#
#     I18n.locale = :es
#
# This would use the information in config/locales/es.yml.
#
# To learn more, please read the Rails Internationalization guide
# available at http://guides.rubyonrails.org/i18n.html.

en = {}

en[:error_message_repeat] = 'Please try again.'
                            ' If this keeps happening please email'
                            " <a href=\"mailto:#{$config.support_email}\">#{$config.support_email}</a>."
  
en[:error_message_default] = "There was an error. #{en[:error_message_repeat]}"

en[:gmail] = {
  :access_not_granted => "You did not grant #{$config.service_name_short} access to Gmail. Please try again.",
  :authenticated => 'Gmail authenticated!',
  :unlinked => 'Your Gmail account has been unlinked.'
}

return {'en' => en}
