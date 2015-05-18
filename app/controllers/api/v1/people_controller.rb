class Api::V1::PeopleController < ApiController
  before_action do
    signed_in_user(true)
  end

  before_action :correct_email_account

  swagger_controller :people, 'People Controller'

  # :nocov:
  swagger_api :recent_thread_subjects do
    summary 'Return 10 most recent threads.'

    param :form, :email, :string, false, 'Email'
    
    response :ok
  end
  # :nocov:

  # TODO write tests
  def recent_thread_subjects
    email = params[:email]
    
    gmail_account = current_user.gmail_accounts.first
    recent_thread_subjects = gmail_account.recent_thread_subjects(email)
    
    render :json => recent_thread_subjects
  end

  # :nocov:
  swagger_api :search do
    summary 'Search people.'

    response :ok
  end
  # :nocov:

  def search
    query = params[:query].gsub(/\s/, '%')
    query = "%#{query}%"
    
    @people = @email_account.people.where('people.name ILIKE ? OR people.email_address ILIKE ?', query, query).limit(6)
    
    render 'api/v1/people/index'
  end
end
