collection @email_template_categories

extends('api/v1/email_template_categories/show')

# for backward-compatibility: existing records don't have cached count
node :email_templates_count do |u|
  u.email_templates.count
end
