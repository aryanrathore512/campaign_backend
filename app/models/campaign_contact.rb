class CampaignContact < ApplicationRecord
  belongs_to :campaign, optional: true
  belongs_to :contact, optional: true
end
