class CampaignTemplate < ApplicationRecord
  belongs_to :campaign, optional: true
  belongs_to :template, optional: true
end