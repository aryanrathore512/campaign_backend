class Template < ApplicationRecord
	has_many :campaign_templates
  	has_many :campaigns, through: :campaign_templates
end
