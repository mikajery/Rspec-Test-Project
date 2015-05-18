class Api::V1::EmailSignaturesController < ApiController
  before_action { signed_in_user(true) }
  
  before_action :correct_user, :except => [:create, :index]

  swagger_controller :email_signatures, 'Email Signatures Controller'

  # :nocov:
  swagger_api :create do
    summary 'Create an email signature.'

    param :form, :name, :string, :required, 'Name'
    param :form, :text, :string, :optional, 'Text'
    param :form, :html, :string, :optional, 'HTML'

    response :ok
  end
  # :nocov:
  
  def create
    begin
      @email_signature = EmailSignature.create!(:user => current_user, :name => params[:name],
                                                :text => params[:text], :html => params[:html])
    rescue ActiveRecord::RecordNotUnique
      render :status => $config.http_errors[:email_signature_name_in_use][:status_code],
             :json => $config.http_errors[:email_signature_name_in_use][:description]
      return
    end
    
    render 'api/v1/email_signatures/show'
  end

  # :nocov:
  swagger_api :index do
    summary 'Return existing email signatures.'

    response :ok
  end
  # :nocov:
  
  def index
    @email_signatures = current_user.email_signatures
  end

  # :nocov:
  swagger_api :show do
    summary 'Return email signature for UID.'

    response :ok
  end
  # :nocov:
  
  def show
    render 'api/v1/email_signatures/show'
  end

  # :nocov:
  swagger_api :update do
    summary 'Update email signature.'

    param :form, :email_signature_uid, :string, :required, 'Email Signature UID'
    param :form, :name, :string, :optional, 'Name'
    param :form, :text, :string, :optional, 'Text'
    param :form, :html, :string, :optional, 'HTML'

    response :ok
  end
  # :nocov:

  def update
    begin
      permitted_params = params.permit(:name, :text, :html)
      @email_signature.update_attributes!(permitted_params)
    rescue ActiveRecord::RecordNotUnique
      render :status => $config.http_errors[:email_signature_name_in_use][:status_code],
             :json => $config.http_errors[:email_signature_name_in_use][:description]
      return
    end

    render 'api/v1/email_signatures/show'
  end

  # :nocov:
  swagger_api :destroy do
    summary 'Delete email signature.'

    param :path, :email_signature_uid, :string, :required, 'Email Signature UID'
    
    response :ok
  end
  # :nocov:

  def destroy
    @email_signature.destroy!

    render :json => {}
  end
  
  private

  # Before filters

  def correct_user
    @email_signature = EmailSignature.find_by(:user => current_user, :uid => params[:email_signature_uid])

    if @email_signature.nil?
      render :status => $config.http_errors[:email_signature_not_found][:status_code],
             :json => $config.http_errors[:email_signature_not_found][:description]
      return
    end
  end
end
