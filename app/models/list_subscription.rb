# == Schema Information
#
# Table name: list_subscriptions
#
#  id                         :integer          not null, primary key
#  email_account_id           :integer
#  email_account_type         :string(255)
#  uid                        :text
#  list_name                  :text
#  list_id                    :text
#  list_subscribe             :text
#  list_subscribe_mailto      :text
#  list_subscribe_email       :text
#  list_subscribe_link        :text
#  list_unsubscribe           :text
#  list_unsubscribe_mailto    :text
#  list_unsubscribe_email     :text
#  list_unsubscribe_link      :text
#  list_domain                :text
#  most_recent_email_date     :datetime
#  unsubscribe_delayed_job_id :integer
#  unsubscribed               :boolean          default(FALSE)
#  created_at                 :datetime
#  updated_at                 :datetime
#

require 'open-uri'

class ListSubscription < ActiveRecord::Base
  serialize :list_subscribe_email
  serialize :list_unsubscribe_email
  
  belongs_to :email_account, polymorphic: true

  validates :email_account, :uid, :list_unsubscribe, presence: true

  before_validation { self.uid = SecureRandom.uuid() if self.uid.nil? }

  def ListSubscription.perform_list_action(email_account, link = nil, email = nil, mailto = nil)
    success = false

    if !success && email
      begin
        log_console("List using EMAIL #{email}")

        tos = [email]
        email_account.send_email(tos)

        success = true
      rescue
      end
    end

    if !success && mailto
      begin
        log_console("List using MAILTO #{mailto}")

        tos = []
        ccs = []
        bccs = []
        subject = nil
        body = nil

        uri = URI(mailto)

        tos.push(uri.to) if uri.to

        uri.headers.each do |header|
          if !header[1].blank?
            headerName = header[0].downcase

            if headerName == 'to'
              tos.concat(header[1].split(','))
            elsif headerName == 'cc'
              ccs.concat(header[1].split(','))
            elsif headerName == 'bcc'
              bccs.concat(header[1].split(','))
            elsif headerName == 'subject'
              subject = header[1]
            elsif headerName == 'body'
              body = header[1]
            end
          end
        end

        email_account.send_email(tos, ccs, bccs, subject, nil, body)

        success = true
      rescue
      end
    end

    if !success && link
      begin
        log_console("List using LINK #{link}")
        open(link)

        success = true
      rescue
      end
    end

    return success
  end
  
  def ListSubscription.get_domain(list_subscription, email_raw)
    domain = nil
    
    # unsubscribe
    
    if domain.blank? && list_subscription.list_unsubscribe_link
      ignore_exception() do
        uri = URI(list_subscription.list_unsubscribe_link)
        domain = uri.host
      end
    end
    
    if domain.blank? && list_subscription.list_unsubscribe_email
      domain = list_subscription.list_unsubscribe_email[:address].split('@')[-1]
    end
    
    # ID
    
    if domain.blank? && list_subscription.list_id
      domain = list_subscription.list_id.split('@')[-1]
    end

    # subscribe
    
    if domain.blank? && list_subscription.list_subscribe_link
      ignore_exception() do
        uri = URI(list_subscription.list_subscribe_link)
        domain = uri.host
      end
    end

    if domain.blank? && list_subscription.list_subscribe_email
      domain = list_subscription.list_subscribe_email[:address].split('@')[-1]
    end
    
    # from address
    
    if domain.blank?
      froms_parsed = parse_email_address_field(email_raw, :from)

      if froms_parsed.length > 0
        from_name, from_address = froms_parsed[0][:display_name], froms_parsed[0][:address]
        domain = from_address.split('@')[-1]
      end
    end
    
    if domain
      return domain.split('.')[-2..-1].join('.')
    else
      return nil
    end
  rescue
    return nil
  end
  
  def ListSubscription.create_from_email_raw(email_account, email_raw)
    list_subscription = ListSubscription.new()
    list_subscription.email_account = email_account

    if email_raw.header['List-Unsubscribe']
      list_subscription.list_unsubscribe = email_raw.header['List-Unsubscribe'].decoded.force_utf8(true)

      subscription_info = parse_email_list_subscription_header(list_subscription.list_unsubscribe)
      list_subscription.list_unsubscribe_mailto = subscription_info[:mailto]
      list_subscription.list_unsubscribe_email = subscription_info[:email]
      list_subscription.list_unsubscribe_link = subscription_info[:link]
      
      return nil if list_subscription.list_unsubscribe_mailto.nil? &&
                    list_subscription.list_unsubscribe_email.nil? &&
                    list_subscription.list_unsubscribe_link.nil?
    else
      return nil
    end

    if email_raw.header['List-Subscribe']
      list_subscription.list_subscribe = email_raw.header['List-Subscribe'].decoded.force_utf8(true)

      subscription_info = parse_email_list_subscription_header(list_subscription.list_subscribe)
      list_subscription.list_subscribe_mailto = subscription_info[:mailto]
      list_subscription.list_subscribe_email = subscription_info[:email]
      list_subscription.list_subscribe_link = subscription_info[:link]
    end
    
    if email_raw.header['List-ID']
      list_id_header_parsed = parse_email_list_id_header(email_raw.header['List-ID'])
      
      list_subscription.list_name = list_id_header_parsed[:name]
      list_subscription.list_id = list_id_header_parsed[:id]

      if list_subscription.list_name.nil?
        list_id_parts = list_subscription.list_id.split('.')
        list_subscription.list_name = list_id_parts[0].gsub(/[_-]/,' ').split.map(&:capitalize).join(' ')
      end
    end
    
    # try from address
    
    if list_subscription.list_name.nil?
      froms_parsed = parse_email_address_field(email_raw, :from)
      
      if froms_parsed.length > 0
        from_name, from_address = froms_parsed[0][:display_name], froms_parsed[0][:address]

        if !from_name.blank?
          list_subscription.list_name = from_name
        else
          list_subscription.list_name = from_address.split('@')[0]
        end
      end
    end

    list_subscription.list_domain = ListSubscription.get_domain(list_subscription, email_raw)

    list_subscriptions_found = []
    
    retry_block do
      list_subscriptions_found = email_account.list_subscriptions.where([
        '(list_id=? AND list_domain=?) OR list_unsubscribe=? OR list_unsubscribe_mailto=? OR list_unsubscribe_email=? OR list_unsubscribe_link=?',
        list_subscription.list_id, list_subscription.list_domain,
        list_subscription.list_unsubscribe,
        list_subscription.list_unsubscribe_mailto,
        list_subscription.list_unsubscribe_email.to_yaml,
        list_subscription.list_unsubscribe_link
      ])
      
      if list_subscriptions_found.count == 0
        list_subscription.save!
        list_subscriptions_found = [list_subscription]
      end
    end

    list_subscriptions_found.each do |list_subscription_found|
      if email_raw.date &&
         (
          list_subscription_found.most_recent_email_date.nil? ||
          (email_raw.date > list_subscription_found.most_recent_email_date && email_raw.date <= DateTime.now())
         )
  
        list_subscription_found.list_name = list_subscription.list_name
        list_subscription_found.list_id = list_subscription.list_id
  
        list_subscription_found.list_subscribe = list_subscription.list_subscribe
        list_subscription_found.list_subscribe_mailto = list_subscription.list_subscribe_mailto
        list_subscription_found.list_subscribe_email = list_subscription.list_subscribe_email
        list_subscription_found.list_subscribe_link = list_subscription.list_subscribe_link
  
        list_subscription_found.list_unsubscribe = list_subscription.list_unsubscribe
        list_subscription_found.list_unsubscribe_mailto = list_subscription.list_unsubscribe_mailto
        list_subscription_found.list_unsubscribe_email = list_subscription.list_unsubscribe_email
        list_subscription_found.list_unsubscribe_link = list_subscription.list_unsubscribe_link
  
        list_subscription_found.list_domain = list_subscription.list_domain
        
        list_subscription_found.most_recent_email_date = email_raw.date
  
        list_subscription_found.save!
      end
    end
      
    return list_subscriptions_found[0]
  rescue Exception
    return nil
  end
  
  def unsubscribe
    log_console("List UNSUBSCRIBE #{self.id}")
    
    unsubscribed =
      ListSubscription.perform_list_action(self.email_account,
                                           self.list_unsubscribe_link,
                                           self.list_unsubscribe_email,
                                           self.list_unsubscribe_mailto)        

    log_console("List UNSUBSCRIBE #{self.id} - unsubscribed=#{unsubscribed}")

    self.unsubscribe_delayed_job_id = nil
    self.unsubscribed = true
    self.save!
  end
  
  def resubscribe
    log_console("List RESUBSCRIBE #{self.id}")
    
    job = Delayed::Job.find_by(id: self.unsubscribe_delayed_job_id)
    if job
      log_console('RESUBSCRIBE found JOB - destroying it!')
      
      job.with_lock do
        job.destroy!
      end
    end

    if self.unsubscribed && self.unsubscribe_delayed_job_id.nil?
      log_console('RESUBSCRIBE is unsubscribed - resubscribing!')
      
      subscribed =
        ListSubscription.perform_list_action(self.email_account,
                                             self.list_subscribe_link,
                                             self.list_subscribe_email,
                                             self.list_subscribe_mailto)
  
      log_console("List SUBSCRIBE #{self.id} - subscribed=#{subscribed}")
    end
    
    self.unsubscribe_delayed_job_id = nil
    self.unsubscribed = false
    self.save!
  end
end
