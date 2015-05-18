class AdminConstraint
  include SessionsHelper

  def cookies
    @cookies
  end

  def matches?(request)
    # hack for overriding cookies
    @cookies = request.cookies.symbolize_keys

    current_user.try :admin?
  end
end
