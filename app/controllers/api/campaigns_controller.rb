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
		@campaign = Campaign.new(campaign_params)
		if @campaign.save
			render json: @campaign, status: :created
		else
			render json: template.errors, status: :unprocessable_entity
		end
	end

	private

	def campaign_params
		params.permit(:name, :campaign_type, :status, :email_limit, :start_time, :end_time, :campaign_run_time )
	end
end
