class Contact < ApplicationRecord
	has_many :campaign_contacts
  	has_many :campaigns, through: :campaign_contacts

  	def self.ransackable_attributes(auth_object = nil)
	    ["id", "name", "address", "age", "email", "updated_at", "created_at"]
	end
end
