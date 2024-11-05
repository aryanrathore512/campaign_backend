class Template < ApplicationRecord
  has_many :campaign_templates
  has_many :campaigns, through: :campaign_templates

  validates :title, presence: { message: 'Template title is required' }
  validates :body, presence: { message: 'Template body is required' }
end
