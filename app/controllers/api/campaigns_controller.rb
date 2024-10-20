class Api::CampaignsController < ApplicationController
	before_action :set_campaign, only: [:show]

	def index
		@campaigns = Campaign.page(params[:page]).per(params[:per_page] || 10)
		render json: @campaigns
	end

	def show
		render json: @campaign
	end

	def create
		@campaign = Campaign.new(campaign_params)

		if @campaign.save
			create_campaign_templates if params[:selectedTemplateIds].present?
			create_campaign_contacts if params[:selectedContactIds].present?

			render json: @campaign, status: :created
		else
			render json: @campaign.errors.full_messages, status: :unprocessable_entity
		end
	end

	private

	def campaign_params
		params.require(:campaign).permit(:name, :campaign_type, :status, :email_limit, :start_time, :end_time, :campaign_run_time)
	end

	def set_campaign
		@campaign = Campaign.find(params[:id])
	rescue ActiveRecord::RecordNotFound
		render json: { error: 'Campaign not found' }, status: :not_found
	end

	def create_campaign_templates
		params[:selectedTemplateIds].each do |template_id|
			CampaignTemplate.create!(campaign_id: @campaign.id, template_id: template_id)
		end
	end

	def create_campaign_contacts
		params[:selectedContactIds].each do |contact_id|
			CampaignContact.create!(campaign_id: @campaign.id, contact_id: contact_id)
		end
	end
end
