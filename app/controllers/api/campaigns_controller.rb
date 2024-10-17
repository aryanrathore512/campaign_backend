class Api::CampaignsController < ApplicationController
	def index
		@campaigns = Campaign.all
		render json: @campaigns
	end

	def show
    	@campaign = Campaign.find(params[:id])
    	render json: @campaign
	end

	def create
	  @campaign = Campaign.new(campaign_params.except(:selectedTemplateIds, :selectedContactIds))

	  if @campaign.save
	    if params[:selectedTemplateIds].present?
	      params[:selectedTemplateIds].each do |template_id|
	        CampaignTemplate.create(campaign_id: @campaign.id, template_id: template_id)
	      end
	    end

	    if params[:selectedContactIds].present?
	      params[:selectedContactIds].each do |contact_id|
	        CampaignContact.create(campaign_id: @campaign.id, contact_id: contact_id)
	      end
	    end

	    render json: @campaign, status: :created
	  else
	    render json: @campaign.errors, status: :unprocessable_entity
	  end
	end


	private

	def campaign_params
		params.permit(:name, :campaign_type, :status, :email_limit, :start_time, :end_time, :campaign_run_time )
	end
end
