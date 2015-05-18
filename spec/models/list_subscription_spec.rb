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

require 'rails_helper'

RSpec.describe ListSubscription, :type => :model do
  let!(:email_account) { FactoryGirl.create(:gmail_account) }

  # relationship
  it { should belong_to :email_account }

  # serialize
  it { should serialize(:list_subscribe_email) }
  it { should serialize(:list_unsubscribe_email) }

  # columns
  it { should have_db_column(:email_account_id).of_type(:integer)  }
  it { should have_db_column(:email_account_type).of_type(:string)  }
  it { should have_db_column(:uid).of_type(:text)  }
  it { should have_db_column(:list_name).of_type(:text)  }
  it { should have_db_column(:list_id).of_type(:text)  }
  it { should have_db_column(:list_subscribe).of_type(:text)  }
  it { should have_db_column(:list_subscribe_mailto).of_type(:text)  }
  it { should have_db_column(:list_subscribe_email).of_type(:text)  }
  it { should have_db_column(:list_subscribe_link).of_type(:text)  }
  it { should have_db_column(:list_unsubscribe).of_type(:text)  }
  it { should have_db_column(:list_unsubscribe_mailto).of_type(:text)  }
  it { should have_db_column(:list_unsubscribe_email).of_type(:text)  }
  it { should have_db_column(:list_unsubscribe_link).of_type(:text)  }
  it { should have_db_column(:list_domain).of_type(:text)  }
  it { should have_db_column(:most_recent_email_date).of_type(:datetime)  }
  it { should have_db_column(:unsubscribe_delayed_job_id).of_type(:integer)  }
  it { should have_db_column(:unsubscribed).of_type(:boolean)  }
  it { should have_db_column(:created_at).of_type(:datetime)  }
  it { should have_db_column(:updated_at).of_type(:datetime)  }

  # indexes
  it { should have_db_index([:email_account_id, :list_id, :list_domain]).unique(true) }
  it { should have_db_index([:email_account_id, :list_unsubscribe]).unique(true) }
  it { should have_db_index([:email_account_id, :list_unsubscribe_email]).unique(true) }
  it { should have_db_index([:email_account_id, :list_unsubscribe_link]).unique(true) }
  it { should have_db_index([:email_account_id, :list_unsubscribe_mailto]).unique(true) }
  it { should have_db_index(:uid).unique(true) }

  # validation
  it { should validate_presence_of(:email_account) }
  it { should validate_presence_of(:list_unsubscribe) }
  it "populates the uid before validation" do
    list_subscription = FactoryGirl.build(:list_subscription, email_account: email_account, uid: nil)
     
    expect(list_subscription.save).to be(true)
  end

  # class methods
  describe "#perform_list_action" do
    
    context "for the given email" do
      let(:email) { FFaker::Internet.email }

      before(:each) {
        allow(email_account).to receive(:send_email).with([email])
      }

      it 'calls the send_email method of the email_account' do

        ListSubscription.perform_list_action(email_account, nil, email)

        expect(email_account).to have_received(:send_email).with([email])
      end

      it 'returns true' do
        expect( ListSubscription.perform_list_action(email_account, nil, email) ).to be(true)
      end
    end #__End of context "for the given email"__

    context "for the given mailto" do
      let(:to) { FFaker::Internet.email }
      let(:another_to) { FFaker::Internet.email }
      let(:cc) { FFaker::Internet.email }
      let(:bcc) { FFaker::Internet.email }
      let(:subject) { FFaker::Lorem.word }
      let(:body) { FFaker::Lorem.word }

      before(:each) {
        allow(email_account).to receive(:send_email)
      }

      let(:mailto) {
        URI::MailTo.build({ :to => to, 
                            :headers => [ ['subject', subject],
                                          ['to', another_to], 
                                          ['cc', cc],
                                          ['bcc', bcc],
                                          ['subject', subject],
                                          ['body', body]
                                        ]
                            }
                          )
      }

      it 'calls the send_email method of the email_account' do

        ListSubscription.perform_list_action(email_account, nil, nil, mailto)

        expect(email_account).to have_received(:send_email).with([to, another_to], [cc], [bcc], subject, nil, body)
      end

      it 'returns true' do
        expect( ListSubscription.perform_list_action(email_account, nil, nil, mailto) ).to be(true)
      end
    end #__End of context "for the given mailto"__

    context "for the given link" do
      let(:link) { "www.google.com" }


      it 'opens the link' do
        ListSubscription.perform_list_action(email_account, link, nil, nil)
      end

      it 'returns false' do
        expect( ListSubscription.perform_list_action(email_account, link, nil, nil) ).to be(false)
      end
    end #__End of context "for the given link"__
  end #__End of describe "#perform_list_action"__

  describe "#get_domain" do
    let(:link) { "http://www.google.com" }
    let(:sample_email) { FFaker::Internet.email }
    let(:serialized_email) { {:address => FFaker::Internet.email} }

    context "the list_unsubscribe_link of the list_subscription exists" do
      let(:list_subscription) { FactoryGirl.create(:list_subscription, email_account: email_account, list_unsubscribe_link: link) }  

      it 'returns the domain of the list_unsubscribe_link' do

        uri = URI(list_subscription.list_unsubscribe_link)
        domain = uri.host

        expected = domain.split('.')[-2..-1].join('.')

        expect( ListSubscription.get_domain(list_subscription, nil) ).to eq(expected)
      end
    end #__End of context "the list_unsubscribe_link of the list_subscription exists"__

    context "the list_unsubscribe_email of the list_subscription exists" do
      let(:list_subscription) { FactoryGirl.create(:list_subscription, email_account: email_account, list_unsubscribe_email: serialized_email) }  

      it 'returns the domain of the list_unsubscribe_email' do

        domain = list_subscription.list_unsubscribe_email[:address].split('@')[-1]

        expected = domain.split('.')[-2..-1].join('.')

        expect( ListSubscription.get_domain(list_subscription, nil) ).to eq(expected)
      end
    end #__End of context "the list_unsubscribe_email of the list_subscription exists"__

    context "the list_id of the list_subscription exists" do
      let(:list_subscription) { FactoryGirl.create(:list_subscription, email_account: email_account, list_id: sample_email) }  

      it 'returns the domain of the list_id' do

        domain = list_subscription.list_id.split('@')[-1]

        expected = domain.split('.')[-2..-1].join('.')

        expect( ListSubscription.get_domain(list_subscription, nil) ).to eq(expected)
      end
    end #__End of context "the list_id of the list_subscription exists"__

    context "the list_subscribe_link of the list_subscription exists" do
      let(:list_subscription) { FactoryGirl.create(:list_subscription, email_account: email_account, list_id: nil, list_subscribe_link: link) }  

      it 'returns the domain of the list_subscribe_link' do

        uri = URI(list_subscription.list_subscribe_link)
        domain = uri.host

        expected = domain.split('.')[-2..-1].join('.')

        expect( ListSubscription.get_domain(list_subscription, nil) ).to eq(expected)
      end
    end #__End of context "the list_subscribe_link of the list_subscription exists"__

    context "the list_subscribe_email of the list_subscription exists" do
      let(:list_subscription) { FactoryGirl.create(:list_subscription, email_account: email_account, list_id: nil, list_subscribe_email: serialized_email) }  

      it 'returns the domain of the list_subscribe_email' do

        domain = list_subscription.list_subscribe_email[:address].split('@')[-1]

        expected = domain.split('.')[-2..-1].join('.')

        expect( ListSubscription.get_domain(list_subscription, nil) ).to eq(expected)
      end
    end #__End of context "the list_subscribe_email of the list_subscription exists"__

    context "the neither list_unsubscribe_link nor list_unsubscribe_email nor list_id nor list_subscribe_link nor list_subscribe_email" do
      let(:list_subscription) { FactoryGirl.create(:list_subscription, email_account: email_account, list_id: nil) }  
      
      context "for the invalid raw email" do
        it 'returns nil' do
          email_raw = nil
          expect( ListSubscription.get_domain(list_subscription, email_raw) ).to be(nil)
        end
      end

      it 'returns the domain of the from email address' do
        raw_from = "sample@email.com"

        email_raw = Mail.new do
          from raw_from
        end

        expected = raw_from.split('@').last

        expect( ListSubscription.get_domain(list_subscription, email_raw) ).to eq(expected)
      end
    end #__End of context "the neither list_unsubscribe_link nor list_unsubscribe_email nor list_id nor list_subscribe_link nor list_subscribe_email"__
  end #__End of describe "#get_domain"__  

  describe "#create_from_email_raw" do
    let(:email_raw) {
      Mail.new do
        from FFaker::Internet.email
        to FFaker::Internet.email
        subject FFaker::Lorem.word
        date Time.now
      end
    }

    let(:display_name) { FFaker::Name.name }
    let(:email) { FFaker::Internet.email }
    let(:mailto) { "mailto:activists-request@lists.stanford.edu?subject=subscribe" }
    let(:link) { "https://mailman.stanford.edu/mailman/listinfo/activists" }

    context "when the List-Unsubscribe of the email header is given" do
      before(:each) {
        email_raw.header['List-Unsubscribe'] = "#{display_name}<#{email}>, <#{link}>, <#{mailto}>"
      }

      it 'saves the from name of the raw email to the list_name field' do
        email_raw.header['from'] = "#{display_name}<#{email}>"

        list_subscription = ListSubscription.create_from_email_raw(email_account, email_raw)

        expect( list_subscription.list_name ).to eq(display_name)
      end

      it 'creates new list subscription with the raw email' do
        expect { ListSubscription.create_from_email_raw(email_account, email_raw) }.to change {ListSubscription.count}.by(1)
      end

      it 'returns the new list subscription with the raw email' do
        expect( ListSubscription.create_from_email_raw(email_account, email_raw).class ).to eq(ListSubscription)
      end

      it 'saves the display name and the email of the List-Unsubscribe header to the list_unsubscribe_email field' do
        expected = {:display_name => display_name, :address => email}

        list_subscription = ListSubscription.create_from_email_raw(email_account, email_raw)
        
        expect( list_subscription.list_unsubscribe_email ).to eq(expected)
      end

      it 'saves the mailto of the List-Unsubscribe header to the list_unsubscribe_mailto field' do
        list_subscription = ListSubscription.create_from_email_raw(email_account, email_raw)
        
        expect( list_subscription.list_unsubscribe_mailto ).to eq(mailto)
      end

      it 'saves the link of the List-Unsubscribe header to the list_unsubscribe_link field' do
        list_subscription = ListSubscription.create_from_email_raw(email_account, email_raw)
        
        expect( list_subscription.list_unsubscribe_link ).to eq(link)
      end

      context "when the List-Subscribe of the email header is given" do
        before(:each) {
          email_raw.header['List-Subscribe'] = "#{display_name}<#{email}>, <#{link}>, <#{mailto}>"
        }

        it 'saves the display name and the email of the List-Subscribe header to the list_subscribe_email field' do
          expected = {:display_name => display_name, :address => email}

          list_subscription = ListSubscription.create_from_email_raw(email_account, email_raw)
          
          expect( list_subscription.list_subscribe_email ).to eq(expected)
        end

        it 'saves the mailto of the List-Subscribe header to the list_subscribe_mailto field' do
          list_subscription = ListSubscription.create_from_email_raw(email_account, email_raw)
          
          expect( list_subscription.list_subscribe_mailto ).to eq(mailto)
        end

        it 'saves the link of the List-Subscribe header to the list_subscribe_link field' do
          list_subscription = ListSubscription.create_from_email_raw(email_account, email_raw)
          
          expect( list_subscription.list_subscribe_link ).to eq(link)
        end
      end #__End of describe "when the List-Subscribe of the email header is given"__     

      context "when the List-ID of the email header is given" do
        let(:list_name) { FFaker::Name.name }
        let(:list_id) { FFaker::Internet.email }

        context "when the name of the List-ID header is given" do
          before(:each) {
            email_raw.header['List-ID'] = "#{list_name}<#{list_id}>"
          }

          it 'saves the name of the List-ID header to the list_name field' do
            list_subscription = ListSubscription.create_from_email_raw(email_account, email_raw)
            
            expect( list_subscription.list_name ).to eq(list_name)
          end
          
          it 'saves the id of the List-ID header to the list_id field' do
            list_subscription = ListSubscription.create_from_email_raw(email_account, email_raw)
            
            expect( list_subscription.list_id ).to eq(list_id)
          end
        end
        
        context "when the name of the List-ID header is not given" do
          before(:each) {
            email_raw.header['List-ID'] = "<#{list_id}>"
          }

          it 'saves the name from the list id of the List-ID header to the list_name field' do
            list_id_parts = list_id.split('.')
            expected = list_id_parts[0].gsub(/[_-]/,' ').split.map(&:capitalize).join(' ')

            list_subscription = ListSubscription.create_from_email_raw(email_account, email_raw)
            
            expect( list_subscription.list_name ).to eq(expected)
          end
          
          it 'saves the id of the List-ID header to the list_id field' do
            list_subscription = ListSubscription.create_from_email_raw(email_account, email_raw)
            
            expect( list_subscription.list_id ).to eq(list_id)
          end
        end    
      end #__End of describe "when the List-ID of the email header is given"__
    end #__End of describe "when the List-Unsubscribe of the email header is given"__ 
    
    context "when the List-Unsubscribe of the email header is not given" do
      it 'does not create new list subscription with the raw email' do
        ListSubscription.create_from_email_raw(email_account, email_raw)

        expect( ListSubscription.count ).to eq(0)
      end

      it 'returns the new list subscription with the raw email' do
        expect( ListSubscription.create_from_email_raw(email_account, email_raw) ).to be(nil)
      end
    end #__End of describe "when the List-Unsubscribe of the email header is not given"__

    context "when the exception occurs" do
      it 'returns nil' do
        allow(ListSubscription).to receive(:new) { 
          raise Exception
        }

        expect( ListSubscription.create_from_email_raw(email_account, email_raw) ).to be(nil)
      end
    end
  end #__End of describe "#create_from_email_raw"__  

  describe ".unsubscribe" do
    let(:list_subscription) { FactoryGirl.create(:list_subscription, email_account: email_account) }

    before(:each) {
      allow(ListSubscription).to receive(:perform_list_action) { true }
    }
    
    it 'calls the perform_list_action method' do

      list_subscription.unsubscribe

      expect(ListSubscription).to have_received(:perform_list_action)
    end

    it 'saves the nil to the unsubscribe_delayed_job_id field' do
      list_subscription.unsubscribe

      expect(list_subscription.unsubscribe_delayed_job_id).to be(nil)
    end

    it 'saves the true to the unsubscribed field' do
      list_subscription.unsubscribe

      expect(list_subscription.unsubscribed).to be(true)
    end
  end #__End of describe ".unsubscribe"__  

  describe ".resubscribe" do
    let(:list_subscription) { FactoryGirl.create(:list_subscription, email_account: email_account) }

    it 'saves the nil to the unsubscribe_delayed_job_id field' do
      list_subscription.resubscribe

      expect(list_subscription.unsubscribe_delayed_job_id).to be(nil)
    end

    it 'saves the true to the unsubscribed field' do
      list_subscription.resubscribe

      expect(list_subscription.unsubscribed).to be(false)
    end

    context "when the delayed job exists" do
      let(:delayed_job) { Delayed::Job.new }

      it 'destroys the delayed job' do
        allow(Delayed::Job).to receive(:find_by) { delayed_job }
        allow(delayed_job).to receive(:destroy!) { true }

        list_subscription.resubscribe

        expect(delayed_job).to have_received(:destroy!)
      end
    end

    context "when the unsubscribed is given and the unsubscribe_delayed_job_id is nil" do
      before(:each) {
        list_subscription.unsubscribed = true
        list_subscription.unsubscribe_delayed_job_id = nil
      }

      it 'calls the perform_list_action method' do
        allow(ListSubscription).to receive(:perform_list_action) { true }

        list_subscription.resubscribe

        expect(ListSubscription).to have_received(:perform_list_action)
      end
    end
  end #__End of describe ".resubscribe"__    

end
