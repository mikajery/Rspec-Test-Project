class ApiController < ApplicationController
  include Swagger::Docs::ImpotentMethods

  skip_before_action :verify_authenticity_token
end
