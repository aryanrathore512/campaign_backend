class Campaign < ApplicationRecord
  include AASM

  has_many :campaign_templates
  has_many :templates, through: :campaign_templates
  has_many :campaign_contacts
  has_many :contacts, through: :campaign_contacts

  after_commit :schedule_email_job


  aasm column: 'status' do
    state :draft, initial: true
    state :initiated
    state :pause
    state :disabled

    event :initiate_campaign do
      transitions from: :draft, to: :initiated
    end

    event :pause_campaign do
      transitions from: :initiated, to: :pause
    end

    event :resume_campaign do
      transitions from: :pause, to: :initiated
    end

    event :disable_campaign do
      transitions from: [:draft, :initiated, :pause], to: :disabled
    end

    event :reactivate_campaign do
      transitions from: :disabled, to: :initiated
    end

    event :return_to_pause do
      transitions from: :disabled, to: :pause
    end
  end

  private

  def schedule_email_job
    return unless aasm.current_state == :initiated

    campaign_contact_ids = contacts.pluck(:id)
    campaign_templates = templates
    batch_size = batch_contact
    current_time = Time.current.utc
    emails_scheduled_today = 0

    template_start_index = last_sent_template_index || 0
    contact_start_index = last_sent_contact_index || 0

    campaign_templates.each_with_index do |template, template_index|
      next if template_index < template_start_index

      contact_batches = campaign_contact_ids.each_slice(batch_size).to_a

      contact_batches.each_with_index do |contact_batch, batch_index|
        if template_index == template_start_index && batch_index == 0
          contact_batch = contact_batch[contact_start_index..-1]
        end

        batch_send_time = current_time + (batch_index * campaign_run_time).hours

        if template_index > 0
          interval = interval_after_first_template * template_index
          batch_send_time += interval.days
        end

        if emails_scheduled_today >= email_limit
          current_time = current_time.beginning_of_day + 1.day
          emails_scheduled_today = 0
          next
        end

        if batch_send_time.between?(start_time, end_time)
          contact_batch.each_with_index do |contact_id, contact_idx|
            CampaignEmailSenderJob.perform_at(batch_send_time, contact_id, template.id)
            emails_scheduled_today += 1

            update_columns(last_sent_template_index: template_index,
                           last_sent_contact_index: contact_idx)

            break if emails_scheduled_today >= email_limit
          end
        end
      end
    end
  end
end
