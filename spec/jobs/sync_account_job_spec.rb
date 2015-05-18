require 'rails_helper'

describe SyncAccountJob do
  let(:gmail_account) { FactoryGirl.create :gmail_account }

  before { expect(gmail_account).to receive(:sync_account).once }

  it "calls #sync_account for gmail account" do
    SyncAccountJob.perform_now(gmail_account)
  end

  it "resets sync_lock" do
    SyncAccountJob.perform_now(gmail_account)
    gmail_account.reload

    expect(gmail_account.sync_lock).to be_falsey
  end
end
