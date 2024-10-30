class Campaign < ApplicationRecord
  include AASM

  has_many :campaign_templates
  has_many :templates, through: :campaign_templates
  has_many :campaign_contacts
  has_many :contacts, through: :campaign_contacts

  validates :name, presence: { message: 'Campaign name is required' }
  validates :campaign_type, presence: { message: 'Campaign type is required' }
  validates :email_limit, presence: { message: 'Email limit is required' }
  validates :start_time, presence: { message: 'Start time is required' }
  validates :end_time, presence: { message: 'End time is required' }
  validates :campaign_run_time, presence: { message: 'Campaign run time is required' }
  validates :batch_contact, presence: { message: 'Campaign batch contact is required' }

  after_commit :schedule_email_job

  validate :start_time_must_be_before_end_time

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
      transitions from: [:initiated, :pause], to: :disabled
    end
  end

  private

  def start_time_must_be_before_end_time
    return if start_time.blank? || end_time.blank?

    if start_time >= end_time
      errors.add(:start_time, 'must be less than End time')
    end
  end

  def schedule_email_job
    if aasm.current_state == :saved
      contacts = self.contacts.pluck(:id)
      templates = self.templates
      batch_size = self.batch_contact
      current_time = Time.current.utc

      contacts.each_slice(batch_size).with_index do |contact_batch, batch_index|
        batch_send_time = current_time + ((batch_index + 1) * self.campaign_run_time).hours
        if batch_send_time.between?(self.start_time, self.end_time)
          contact_batch.each do |contact_id|
            templates.each do |template|
              CampaignEmailSenderJob.perform_at(batch_send_time, contact_id, template.id)
            end
          end
        end
      end
    end
  end
end
