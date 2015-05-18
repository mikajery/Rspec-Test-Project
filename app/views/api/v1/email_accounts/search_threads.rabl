node(:next_page_token) do
  @next_page_token
end

node(:email_threads) do
  partial('api/v1/email_threads/index', object: @email_threads)
end
