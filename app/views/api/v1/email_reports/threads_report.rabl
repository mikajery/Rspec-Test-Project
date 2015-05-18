node(:average_thread_length) { @average_thread_length }

node(:top_email_threads) do
  partial('api/v1/email_reports/email_thread_show.rabl', :object => @top_email_threads)
end

