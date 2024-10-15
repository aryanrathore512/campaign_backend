class Contact < ApplicationRecord
	has_many :campaign_contacts
  	has_many :campaigns, through: :campaign_contacts
end
