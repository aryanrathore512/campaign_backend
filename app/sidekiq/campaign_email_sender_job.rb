class CampaignEmailSenderJob
  include Sidekiq::Job

  def perform(*args)
    current_time = Time.now.utc.strftime("%Y-%m-%d %H:%M:%S UTC")
    active_campaigns = Campaign.where('start_time <= ? AND end_time >= ? AND status = ?', current_time, current_time, true)

    if active_campaigns.present?
      active_campaigns.each do |campaign|
        next unless within_campaign_run_time?(campaign)

        contacts = campaign.campaign_contacts.map(&:contact)
        templates = campaign.campaign_templates.map(&:template)

        unsent_contacts = filter_unsent_contacts(campaign, contacts)

        batch_size = campaign.batch_contact

        unsent_contacts.each_slice(batch_size) do |contact_batch|
          break if reached_email_limit?(campaign)

          templates.each do |template|
            contact_batch.each do |contact|
              next if sent_email_today?(campaign, contact)

              CampaignMailer.send_campaign_email(contact, template, campaign).deliver_now

              log_sent_email(campaign, contact)
            end
          end
        end
      end
    end
  end

  private

  def within_campaign_run_time?(campaign)
    last_run_time = campaign.last_run_time || campaign.start_time
    next_run_time = last_run_time + campaign.campaign_run_time.hours
    Time.now >= next_run_time
  end

  def reached_email_limit?(campaign)
    emails_sent_today = CampaignSentEmail.where(campaign_id: campaign.id, created_at: Time.now.beginning_of_day..Time.now.end_of_day).count
    emails_sent_today >= campaign.email_limit
  end

  def sent_email_today?(campaign, contact)
    CampaignSentEmail.where(campaign_id: campaign.id, contact_id: contact.id, created_at: Time.now.beginning_of_day..Time.now.end_of_day).exists?
  end

  def filter_unsent_contacts(campaign, contacts)
    contacts.reject { |contact| CampaignSentEmail.where(campaign_id: campaign.id, contact_id: contact.id).exists? }
  end

  def log_sent_email(campaign, contact)
    CampaignSentEmail.create(campaign_id: campaign.id, contact_id: contact.id)
    campaign.update(last_run_time: Time.now)
  end
end
