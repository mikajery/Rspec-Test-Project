class Api::V1::LogsController < ApiController
  swagger_controller :logs, 'Logs Controller'

  # :nocov:
  swagger_api :log do
    summary 'Log message.'

    response :ok
  end
  # :nocov:
  
  def log
    render :json => {}
  end
end
