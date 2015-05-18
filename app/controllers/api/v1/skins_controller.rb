class Api::V1::SkinsController < ApiController
  before_action do
    signed_in_user(true)
  end

  swagger_controller :skins, 'Skins Controller'

  # :nocov:
  swagger_api :index do
    summary 'Return skins.'

    response :ok
  end
  # :nocov:

  # TODO write tests
  def index
    @skins = Skin.all
  end
end
