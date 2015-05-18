class Api::V1::EmailTemplateCategoriesController < ApiController
  before_action { signed_in_user(true) }

  before_action :correct_user, :except => [:create, :index]

  swagger_controller :email_template_categories, 'Email Template Categories Controller'

  # :nocov:
  swagger_api :create do
    summary 'Create an email template category.'

    param :form, :name, :string, :required, 'Name'

    response :ok
  end
  # :nocov:

  def create
    begin
      @email_template_category = EmailTemplateCategory.create!(:user => current_user, :name => params[:name])
    rescue ActiveRecord::RecordNotUnique
      render :status => $config.http_errors[:email_template_category_name_in_use][:status_code],
             :json => $config.http_errors[:email_template_category_name_in_use][:description]
      return
    end

    render 'api/v1/email_template_categories/show'
  end

  # :nocov:
  swagger_api :index do
    summary 'Return existing email template categories.'

    response :ok
  end
  # :nocov:

  def index
    @email_template_categories = current_user.email_template_categories
  end

  # :nocov:
  swagger_api :update do
    summary 'Update email template category.'

    param :form, :email_template_category_uid, :string, :required, 'Email Template Category UID'
    param :form, :name, :string, :optional, 'Name'

    response :ok
  end
  # :nocov:

  def update
    begin
      permitted_params = params.permit(:name)
      @email_template_category.update_attributes!(permitted_params)
    rescue ActiveRecord::RecordNotUnique
      render :status => $config.http_errors[:email_template_category_name_in_use][:status_code],
             :json => $config.http_errors[:email_template_category_name_in_use][:description]
      return
    end

    render 'api/v1/email_template_categories/show'
  end

  # :nocov:
  swagger_api :destroy do
    summary 'Delete email template category.'

    param :path, :email_template_category_uid, :string, :required, 'Email Template Category UID'

    response :ok
  end
  # :nocov:

  def destroy
    @email_template_category.destroy!

    render :json => {}
  end

  private

  # Before filters

  def correct_user
    @email_template_category = EmailTemplateCategory.find_by(:user => current_user, :uid => params[:email_template_category_uid])

    if @email_template_category.nil?
      render :status => $config.http_errors[:email_template_category_not_found][:status_code],
             :json => $config.http_errors[:email_template_category_name_in_use][:description]
      return
    end
  end
end
