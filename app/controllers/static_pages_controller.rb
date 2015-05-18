class StaticPagesController < ApplicationController
  before_action :signed_in_user, :except => [:landing]
  unless Rails.env.test?
    http_basic_authenticate_with name: "turing", password: "email2"
  end

  def landing
    if current_user
      redirect_to mail_url
      return
    end

    render layout: "landing"
  end

  def mail
  end
end
