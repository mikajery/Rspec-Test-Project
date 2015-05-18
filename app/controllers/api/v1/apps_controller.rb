class Api::V1::AppsController < ApiController
  before_action { signed_in_user(true) }

  before_action :correct_user, :except => [:test, :create, :index, :install, :uninstall]
  before_action :with_app, :only => [:install, :uninstall, :destroy]

  swagger_controller :apps, 'Apps Controller'

  # :nocov:
  swagger_api :test do
    summary 'Test app.'

    param :form, :email_thread, :string, false, 'Email Thread'
    
    response :ok
  end
  # :nocov:
  
  def test
    email_thread = params[:email_thread]
    if email_thread
      emails = email_thread[:emails]
      
      html = "<html><body>HIHIHI!!!!<br />#{emails[(emails.length - 1).to_s]["snippet"]}</body></html>"
    else
      email = params[:email]
      
      html = "<html><body>HIHIHI!!!!<br />#{email["snippet"]}</body></html>"
    end
    
    render :html => html.html_safe
  end

  # :nocov:
  swagger_api :stats do
    summary 'Stats app.'

    param :form, :email_thread, :string, false, 'Email Thread'

    response :ok
  end
  # :nocov:

  # :nocov:
  swagger_api :create do
    summary 'Create an app.'

    param :form, :name, :string, false, 'Name'
    param :form, :description, :string, false, 'Description'
    param :form, :app_type, :string, false, 'App Type'
    param :form, :callback_url, :string, false, 'Callback URL'

    response :ok
  end
  # :nocov:

  def create
    name = params[:name].blank? ? nil : params[:name]
    description = params[:description].blank? ? nil : params[:description]
    app_type = params[:app_type].blank? ? nil : params[:app_type]
    callback_url = params[:callback_url].blank? ? nil : params[:callback_url]

    begin
      App.find_or_create_by!(:user => current_user,
                             :name => name,
                             :description => description,
                             :app_type => app_type,
                             :callback_url => callback_url)
    rescue ActiveRecord::RecordNotUnique
    end

    render :json => {}
  end

  # :nocov:
  swagger_api :index do
    summary 'Return existing apps.'

    response :ok
  end
  # :nocov:

  def index
    @apps = App.all
  end

  # :nocov:
  swagger_api :install do
    summary 'Installs the app.'

    param :path, :app_uid, :string, :required, 'App UID'

    response :ok
  end
  # :nocov:

  def install
    current_user.with_lock do
      installed_app = InstalledApp.find_or_create_by!(:user => current_user, :app => @app)
      
      installed_panel_app = InstalledPanelApp.new()
      installed_panel_app.installed_app = installed_app
      installed_panel_app.save!
      
      installed_app.installed_app_subclass = installed_panel_app
      installed_app.save!
    end

    render :json => {}
  end

  # :nocov:
  swagger_api :uninstall do
    summary 'Uninstalls the app.'

    param :path, :app_uid, :string, :required, 'App UID'

    response :ok
  end
  # :nocov:

  def uninstall
    installed_app = InstalledApp.find_by(:app => @app, :user => current_user)
    installed_app.destroy! if installed_app

    render :json => {}
  end

  # :nocov:
  swagger_api :destroy do
    summary 'Delete app.'

    param :form, :app_uid, :string, :required, 'App UID'

    response :ok
  end
  # :nocov:

  def destroy
    @app.destroy!

    render :json => {}
  end

  private

  # Before filters

  def correct_user
    @app = App.find_by(:user => current_user,
                       :uid => params[:app_uid])

    if @app.nil?
      render :status => $config.http_errors[:app_not_found][:status_code],
             :json => $config.http_errors[:app_not_found][:description]
      return
    end
  end
  
  def with_app
    @app = App.find_by_uid(params[:app_uid])

    if @app.nil?
      render :status => $config.http_errors[:app_not_found][:status_code],
             :json => $config.http_errors[:app_not_found][:description]
      return
    end
  end
end
