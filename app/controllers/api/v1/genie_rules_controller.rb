class Api::V1::GenieRulesController < ApiController
  before_action do
    signed_in_user(true)
  end

  before_action :correct_user, :except => [:create, :index, :recommended_rules]

  swagger_controller :genie_rules, 'Genie Rules Controller'

  # :nocov:
  swagger_api :create do
    summary 'Create a genie rule.'

    param :form, :from_address, :string, false, 'From Address'
    param :form, :to_address, :string, false, 'To Adddress'
    param :form, :subject, :string, false, 'Subject'
    param :form, :list_id, :string, false, 'List ID'

    response :ok
  end
  # :nocov:

  def create
    from_address = params[:from_address].blank? ? nil : params[:from_address]
    to_address = params[:to_address].blank? ? nil : params[:to_address]
    subject = params[:subject].blank? ? nil : params[:subject]
    list_id = params[:list_id].blank? ? nil : params[:list_id]
    
    begin
      GenieRule.find_or_create_by!(:user => current_user,
                                   :from_address => from_address, :to_address => to_address,
                                   :subject => subject, :list_id => list_id)
    rescue ActiveRecord::RecordNotUnique
    end
    
    render :json => {}
  end

  # :nocov:
  swagger_api :index do
    summary 'Return existing genie rules.'

    response :ok
  end
  # :nocov:

  def index
    @genie_rules = current_user.genie_rules
  end

  # :nocov:
  swagger_api :destroy do
    summary 'Delete genie rule.'

    param :path, :genie_rule_uid, :string, :required, 'Genie Rule UID'

    response :ok
  end
  # :nocov:

  def destroy
    @genie_rule.destroy!
    
    render :json => {}
  end

  private

  # Before filters

  def correct_user
    @genie_rule = GenieRule.find_by(:user => current_user,
                                    :uid => params[:genie_rule_uid])

    if @genie_rule.nil?
      render :status => $config.http_errors[:genie_rule_not_found][:status_code],
             :json => $config.http_errors[:genie_rule_not_found][:description]
      return
    end
  end
end
