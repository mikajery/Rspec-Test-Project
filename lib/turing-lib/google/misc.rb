module Google
  class Misc
    MAX_BATCH_REQUESTS = 1000

    def Misc.get_parameters_from_args(args)
      parameters = {}

      args.each { |arg|
        val = arg.values[0]
        parameters[arg.keys[0]] = val if val
      }

      return parameters
    end

    def Misc.get_exception(result)
      case result.status
        when 301, 302, 303, 307
          return Google::APIClient::RedirectError.new(result.headers['location'], result)
        when 400...500
          return Google::APIClient::ClientError.new(result.error_message || "A client error has occurred", result)
        when 500...600
          return Google::APIClient::ServerError.new(result.error_message || "A server error has occurred", result)
        else
          return Google::APIClient::TransmissionError.new(result.error_message || "A transmission error has occurred", result)
      end
    end
  end
end
