object @email_template

attributes :uid, :name, :text, :html

node :category_uid do |u|
  u.email_template_category.uid if u.email_template_category
end
