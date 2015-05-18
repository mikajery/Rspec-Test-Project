module Google
  class GmailClient
    MAX_RATE_LIMIT_ATTEMPTS = 8

    attr_accessor :api_client, :gmail_api

    def GmailClient.handle_client_error(ex, attempts)
      log_console("GmailClient.handle_client_error!!!!!! attempts=#{attempts}")

      if ex.result.data.error.nil? ||
         ex.result.data.error['errors'].nil? || ex.result.data.error['errors'].empty? ||
         (ex.result.data.error['errors'][0]['reason'] != 'userRateLimitExceeded' &&
          ex.result.data.error['errors'][0]['reason'] != 'rateLimitExceeded')

        log_email('gmail client error!!!!', ex.result.data.error['errors'].to_s) if ex.result.data.error.present?
        raise ex
      end

      attempts += 1
      raise ex if attempts >= Google::GmailClient::MAX_RATE_LIMIT_ATTEMPTS

      sleep(2 ** attempts + rand())

      return attempts
    end

    def initialize(api_client)
      self.api_client = api_client
      self.gmail_api = api_client.discovered_api('gmail', 'v1')
    end

    # labels

    def labels_create(userId, name, labelListVisibility: "labelShow", messageListVisibility: "show")
      args = method(__method__).parameters[0...-3].map { |arg| {arg[1] => eval(arg[1].to_s)} }
      parameters = Google::Misc.get_parameters_from_args(args)

      body_object = { :name => name, :labelListVisibility => labelListVisibility,
                      :messageListVisibility => messageListVisibility }

      result = self.api_client.execute!(:api_method => self.gmail_api.users.labels.create,
                                        :parameters => parameters, :body_object => body_object)
      return result.data
    end

    def labels_list(userId, fields: nil)
      args = method(__method__).parameters.map { |arg| {arg[1] => eval(arg[1].to_s)} }
      parameters = Google::Misc.get_parameters_from_args(args)

      result = self.api_client.execute!(:api_method => self.gmail_api.users.labels.list,
                                        :parameters => parameters)
      return result.data
    end

    def labels_get(userId, id, fields: nil)
      args = method(__method__).parameters.map { |arg| {arg[1] => eval(arg[1].to_s)} }
      parameters = Google::Misc.get_parameters_from_args(args)

      result = self.api_client.execute!(:api_method => self.gmail_api.users.labels.get,
                                        :parameters => parameters)
      return result.data
    end

    # threads

    def threads_list(userId, includeSpamTrash: nil, labelIds: nil, maxResults: nil, pageToken: nil, q: nil, fields: nil)
      args = method(__method__).parameters.map { |arg| {arg[1] => eval(arg[1].to_s)} }
      parameters = Google::Misc.get_parameters_from_args(args)

      result =  self.api_client.execute!(:api_method => self.gmail_api.users.threads.list,
                                         :parameters => parameters)
      return result.data
    end

    def threads_get_call(userId, id, format: nil, metadataHeaders: nil, fields: nil)
      args = method(__method__).parameters.map { |arg| {arg[1] => eval(arg[1].to_s)} }
      parameters = Google::Misc.get_parameters_from_args(args)

      return :api_method => self.gmail_api.users.threads.get,
             :parameters => parameters
    end

    def threads_get(userId, id, format: nil, metadataHeaders: nil, fields: nil)
      call = self.threads_get_call(userId, id, fields: fields)
      result = self.api_client.execute!(call)
      return result.data
    end

    # messages

    def messages_list(userId, includeSpamTrash: nil, labelIds: nil, maxResults: nil, pageToken: nil, q: nil, fields: nil)
      args = method(__method__).parameters.map { |arg| {arg[1] => eval(arg[1].to_s)} }
      parameters = Google::Misc.get_parameters_from_args(args)

      result =  self.api_client.execute!(:api_method => self.gmail_api.users.messages.list,
                                         :parameters => parameters)
      return result.data
    end

    def messages_get_call(userId, id, format: nil, fields: nil)
      args = method(__method__).parameters.map { |arg| {arg[1] => eval(arg[1].to_s)} }
      parameters = Google::Misc.get_parameters_from_args(args)

      return :api_method => self.gmail_api.users.messages.get,
             :parameters => parameters
    end

    def messages_get(userId, id, format: nil, fields: nil)
      call = self.messages_get_call(userId, id, format: format, fields: fields)
      result = self.api_client.execute!(call)
      return result.data
    end

    def messages_modify_call(userId, id, addLabelIds: nil, removeLabelIds: nil)
      args = method(__method__).parameters[0...-2].map { |arg| {arg[1] => eval(arg[1].to_s)} }
      parameters = Google::Misc.get_parameters_from_args(args)

      body_object = {}
      body_object[:addLabelIds] = addLabelIds if addLabelIds
      body_object[:removeLabelIds] = removeLabelIds if removeLabelIds

      return :api_method => self.gmail_api.users.messages.modify,
             :parameters => parameters, :body_object => body_object
    end

    def messages_modify(userId, id, addLabelIds: nil, removeLabelIds: nil)
      call = self.messages_modify_call(userId, id, addLabelIds: addLabelIds, removeLabelIds: removeLabelIds)
      result = self.api_client.execute!(call)
      return result.data
    end

    def messages_trash_call(userId, id)
      args = method(__method__).parameters.map { |arg| {arg[1] => eval(arg[1].to_s)} }
      parameters = Google::Misc.get_parameters_from_args(args)

      return :api_method => self.gmail_api.users.messages.trash,
             :parameters => parameters
    end

    def messages_trash(userId, id)
      call = self.messages_trash_call(userId, id)
      result = self.api_client.execute!(call)
      return result.data
    end

    def messages_send(userId, threadId: nil, email_raw: nil)
      args = method(__method__).parameters[0...-2].map { |arg| {arg[1] => eval(arg[1].to_s)} }
      parameters = Google::Misc.get_parameters_from_args(args)

      body_object = { :raw => email_raw ? Base64.urlsafe_encode64(email_raw.encoded_with_bcc) : nil }
      body_object[:threadId] = threadId if threadId

      result = self.api_client.execute!(:api_method => self.gmail_api.users.messages.to_h['gmail.users.messages.send'],
                                        :parameters => parameters, :body_object => body_object)
      return result.data
    end

    # attachments

    def attachments_get_call(userId, messageId, id)
      args = method(__method__).parameters.map { |arg| {arg[1] => eval(arg[1].to_s)} }
      parameters = Google::Misc.get_parameters_from_args(args)

      return :api_method => self.gmail_api.users.messages.attachments.get,
             :parameters => parameters
    end

    def attachments_get(userId, messageId, id)
      call = self.attachments_get_call(userId, messageId, id)
      result = self.api_client.execute!(call)
      return JSON.parse(result.response.body)
    end

    # history

    def history_list(userId, labelId: nil, maxResults: nil, pageToken: nil, startHistoryId: nil)
      args = method(__method__).parameters.map { |arg| {arg[1] => eval(arg[1].to_s)} }
      parameters = Google::Misc.get_parameters_from_args(args)

      result = self.api_client.execute!(:api_method => self.gmail_api.users.history.list,
                                        :parameters => parameters)
      return result.data
    end

    # drafts

    def drafts_list(userId, maxResults: nil, pageToken: nil)
      args = method(__method__).parameters.map { |arg| {arg[1] => eval(arg[1].to_s)} }
      parameters = Google::Misc.get_parameters_from_args(args)

      result = self.api_client.execute!(:api_method => self.gmail_api.users.drafts.list,
                                        :parameters => parameters)
      return result.data
    end

    def drafts_create(userId, threadId: nil, email_raw: nil)
      args = method(__method__).parameters[0...-2].map { |arg| {arg[1] => eval(arg[1].to_s)} }
      parameters = Google::Misc.get_parameters_from_args(args)

      body_object = { :message => {:raw => email_raw ? Base64.urlsafe_encode64(email_raw.encoded_with_bcc) : nil} }
      body_object[:message][:threadId] = threadId if threadId

      result = self.api_client.execute!(:api_method => self.gmail_api.users.drafts.create,
                                        :parameters => parameters, :body_object => body_object)
      return result.data
    end

    def drafts_update(userId, id, threadId: nil, email_raw: nil)
      args = method(__method__).parameters[0...-2].map { |arg| {arg[1] => eval(arg[1].to_s)} }
      parameters = Google::Misc.get_parameters_from_args(args)

      body_object = { :message => {:raw => email_raw ? Base64.urlsafe_encode64(email_raw.encoded_with_bcc) : nil} }
      body_object[:message][:threadId] = threadId if threadId

      result = self.api_client.execute!(:api_method => self.gmail_api.users.drafts.update,
                                        :parameters => parameters, :body_object => body_object)
      return result.data
    end

    def drafts_send(userId, id)
      args = method(__method__).parameters.map { |arg| {arg[1] => eval(arg[1].to_s)} }
      parameters = Google::Misc.get_parameters_from_args(args)

      body_object = { :id => id }

      result = self.api_client.execute!(:api_method => self.gmail_api.users.drafts.to_h['gmail.users.drafts.send'],
                                        :parameters => parameters, :body_object => body_object)
      return result.data
    end

    def drafts_delete(userId, id)
      args = method(__method__).parameters.map { |arg| {arg[1] => eval(arg[1].to_s)} }
      parameters = Google::Misc.get_parameters_from_args(args)

      result = self.api_client.execute!(:api_method => self.gmail_api.users.drafts.delete,
                                        :parameters => parameters)
      return result.data
    end
  end
end
