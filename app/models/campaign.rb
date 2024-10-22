class Campaign < ApplicationRecord
	has_many :campaign_templates
	has_many :templates, through: :campaign_templates
	has_many :campaign_contacts
	has_many :contacts, through: :campaign_contacts
end
