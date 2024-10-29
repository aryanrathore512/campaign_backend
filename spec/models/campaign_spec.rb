require 'rails_helper'

RSpec.describe Campaign, type: :model do
  include ActiveSupport::Testing::TimeHelpers

  let(:campaign) { create(:campaign, start_time: Time.current, end_time: Time.current + 10.hours, campaign_run_time: 1) }
  let(:template) { create(:template) } # assuming you have a template factory
  let!(:contacts) { create_list(:contact, 5) } # assuming you have a contact factory

  before do
    campaign.templates << template
    campaign.contacts << contacts
  end

  describe "#schedule_email_job" do
    it "schedules email jobs for contacts in batches" do
      campaign.save_campaign!

      expect(CampaignEmailSenderJob).to receive(:perform_at).exactly(5).times

      campaign.send(:schedule_email_job)
    end

    it "does not schedule jobs outside the start and end time" do
      travel_to(Time.current + 11.hours) do
        campaign.save_campaign!

        expect(CampaignEmailSenderJob).not_to receive(:perform_at)

        campaign.send(:schedule_email_job)
      end
    end
  end

  it "is valid with valid attributes" do
    expect(campaign).to be_valid
  end

  it "is not valid without a name" do
    campaign.name = nil
    expect(campaign).to_not be_valid
    expect(campaign.errors.messages[:name]).to include("Campaign name is required")
  end

  it "is not valid without a campaign_type" do
    campaign.campaign_type = nil
    expect(campaign).to_not be_valid
    expect(campaign.errors.messages[:campaign_type]).to include("Campaign type is required")
  end

  it "is not valid without an email_limit" do
    campaign.email_limit = nil
    expect(campaign).to_not be_valid
    expect(campaign.errors.messages[:email_limit]).to include("Email limit is required")
  end

  it "changes state correctly" do
    expect(campaign.aasm.current_state).to eq(:draft)

    campaign.save_campaign!
    expect(campaign.aasm.current_state).to eq(:saved)

    campaign.pause_campaign!
    expect(campaign.aasm.current_state).to eq(:pause)

    campaign.resume_campaign!
    expect(campaign.aasm.current_state).to eq(:saved)

    campaign.disable_campaign!
    expect(campaign.aasm.current_state).to eq(:disabled)
  end

  # More tests for callbacks or specific business logic can go here
end
