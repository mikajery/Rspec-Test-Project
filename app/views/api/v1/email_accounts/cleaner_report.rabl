node(:num_important_emails) do
  @num_important_emails
end

node(:num_auto_filed_emails) do
  @num_auto_filed_emails
end

node(:important_emails) do
  partial('api/v1/emails/index', object: @important_emails)
end

node(:auto_filed_emails) do
  partial('api/v1/emails/index', object: @auto_filed_emails)
end
