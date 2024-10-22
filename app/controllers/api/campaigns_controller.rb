class Api::CampaignsController < ApplicationController
  before_action :set_campaign, only: [:show]

  def index
    status_filter = params[:status]
    @campaigns = Campaign.all

    if status_filter.present?
      @campaigns = @campaigns.where(status: status_filter)
    end

    page = params[:page].presence || 1
    per_page = params[:per_page].presence || 10

    @campaigns = @campaigns.page(page).per(per_page)
    render json: @campaigns
  end

  def show
    render json: @campaign
  end

  def create
    @campaign = Campaign.new(campaign_params.except(:selectedTemplateIds, :selectedContactIds))

    if @campaign.save
      create_campaign_templates if params[:campaign][:selectedTemplateIds].present?
      create_campaign_contacts if params[:campaign][:selectedContactIds].present?

      render json: @campaign, status: :created
    else
      render json: @campaign.errors.full_messages, status: :unprocessable_entity
    end
  end

  private

  def campaign_params
    params.require(:campaign).permit(
      :name,
      :campaign_type,
      :status,
      :email_limit,
      :start_time,
      :end_time,
      :campaign_run_time,
      :batch_contact,
      selectedTemplateIds: [],
      selectedContactIds: [],
    )
  end

  def set_campaign
    @campaign = Campaign.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Campaign not found' }, status: :not_found
  end

  def create_campaign_templates
    params[:campaign][:selectedTemplateIds].each do |template_id|
      CampaignTemplate.create!(campaign_id: @campaign.id, template_id: template_id)
    end
  end

  def create_campaign_contacts
    params[:campaign][:selectedContactIds].each do |contact_id|
      CampaignContact.create!(campaign_id: @campaign.id, contact_id: contact_id)
    end
  end
end
