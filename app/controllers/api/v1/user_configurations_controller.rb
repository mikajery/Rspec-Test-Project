class Api::V1::UserConfigurationsController < ApiController
  before_action {  signed_in_user(true) }

  swagger_controller :users, 'User Configurations Controller'

  # :nocov:
  swagger_api :show do
    summary 'Return the user configuration.'

    response :ok
  end
  # :nocov:

  def show
    @user_configuration = current_user.user_configuration
  end

  # :nocov:
  swagger_api :update do
    summary 'Update the user configuration.'

    param :form, :demo_mode_enabled, :boolean, :description => 'Demo Mode status'
    param :form, :genie_enabled, :boolean, :description => 'Genie Enabled status'
    param :form, :split_pane_mode, :string, false, 'Split Pane Mode (off, horizontal, or vertical)'
    param :form, :keyboard_shortcuts_enabled, :string, false, 'Keyboard Shortcuts Enabled status'
    param :form, :developer_enabled, :string, false, 'Developer Enabled status'
    param :form, :email_list_view_row_height, :integer, false, 'Email List View Row Height'
    param :form, :inbox_tabs_enabled, :boolean, :description => 'Inbox Tabs Enabled status'
    param :form, :skin_uid, :string, :description => 'Skin UID'
    param :form, :email_signature_uid, :string, :description => 'Email Signature UID'

    response :ok
  end
  # :nocov:

  def update
    @user_configuration = current_user.user_configuration
    permitted_params = params.permit(:demo_mode_enabled, :genie_enabled, :split_pane_mode,
                                     :keyboard_shortcuts_enabled, :developer_enabled,
                                     :email_list_view_row_height, :inbox_tabs_enabled)
    @user_configuration.update_attributes!(permitted_params)
    
    @user_configuration.skin = Skin.find_by_uid(params[:skin_uid])
    @user_configuration.save!

    @user_configuration.email_signature = EmailSignature.find_by_uid(params[:email_signature_uid])
    @user_configuration.save!

    render 'api/v1/user_configurations/show'
  end
end