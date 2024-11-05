class CampaignEmailSenderJob
  include Sidekiq::Job

  queue_as :default

  def perform(campaign_id, contact_id, template_id)
    campaign = Campaign.find(campaign_id)
    contact = Contact.find(contact_id)
    template = Template.find(template_id)

    CampaignMailer.send_campaign_email(contact, template, campaign).deliver_later
  end
end
