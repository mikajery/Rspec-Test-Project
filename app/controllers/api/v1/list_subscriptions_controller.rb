class Api::V1::ListSubscriptionsController < ApiController
  before_action do
    signed_in_user(true)
  end

  before_action :correct_email_account

  swagger_controller :list_subscriptions, 'List Subscriptions Controller'

  # :nocov:
  swagger_api :index do
    summary 'Return list subscriptions.'

    response :ok
  end
  # :nocov:

  def index
    @list_subscriptions = @email_account.list_subscriptions.
                                         select(:list_id, :list_name, :list_domain, :unsubscribed).
                                         order(:list_name).
                                         uniq
  end

  # :nocov:
  swagger_api :unsubscribe do
    summary 'Unsubscribe from the list.'

    param :form, :list_id, :string, :required, 'List ID'
    param :form, :list_name, :string, :required, 'List Name'
    param :form, :list_domain, :string, :required, 'List Domain'

    response :ok
  end
  # :nocov:

  # TODO write tests
  def unsubscribe
    list_subscriptions = @email_account.list_subscriptions.
                                        where(:list_id => params[:list_id],
                                              :list_name => params[:list_name],
                                              :list_domain => params[:list_domain],
                                              :unsubscribed => false,
                                              :unsubscribe_delayed_job_id => nil)
    
    list_subscriptions.each do |list_subscription|
      job = list_subscription.delay({:run_at => 1.hour.from_now}, heroku_scale: false).unsubscribe()
      
      list_subscription.unsubscribe_delayed_job_id = job.id
      list_subscription.unsubscribed = true
      
      list_subscription.save!
    end

    render :json => {}
  end

  # :nocov:
  swagger_api :resubscribe do
    summary 'Resubscribe to the list.'

    param :form, :list_id, :string, :required, 'List ID'
    param :form, :list_name, :string, :required, 'List Name'
    param :form, :list_domain, :string, :required, 'List Domain'

    response :ok
  end
  # :nocov:

  # TODO write tests
  def resubscribe
    list_subscriptions = @email_account.list_subscriptions.
        where(:list_id => params[:list_id],
              :list_name => params[:list_name],
              :list_domain => params[:list_domain],
              :unsubscribed => true)

    list_subscriptions.each do |list_subscription|
      list_subscription.resubscribe()
    end

    render :json => {}
  end
end
