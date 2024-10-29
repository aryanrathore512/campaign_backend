class Api::CampaignsController < ApplicationController
  before_action :set_campaign, only: [:show, :update_status]

  def index
    page = params[:page].presence || AppConstants::DEFAULT_PAGE
    per_page = params[:per_page].presence || AppConstants::DEFAULT_PER_PAGE

    campaigns = Campaign.page(page).per(per_page)
    total_campaigns = Campaign.count

    render json: {
      all_campaigns: campaigns,
      total_campaigns: total_campaigns,
      current_page: page,
      per_page: per_page
    }
  end

  def update_status
    case params[:status]
    when "saved"
      if @campaign.aasm.current_state == :draft
        if @campaign.save_campaign!
          render json: @campaign
        else
          render json: { error: @campaign.errors.full_messages }, status: :unprocessable_entity
        end
      else
        render json: { error: 'Cannot transition to saved from current state or already saved' }, status: :unprocessable_entity
      end
    when "pause"
      if @campaign.aasm.current_state == :saved
        if @campaign.pause_campaign!
          render json: @campaign
        else
          render json: { error: @campaign.errors.full_messages }, status: :unprocessable_entity
        end
      else
        render json: { error: 'Cannot pause campaign from current state or already paused' }, status: :unprocessable_entity
      end
    when "resume"
      if @campaign.aasm.current_state == :pause
        if @campaign.resume_campaign!
          render json: @campaign
        else
          render json: { error: @campaign.errors.full_messages }, status: :unprocessable_entity
        end
      else
        render json: { error: 'Cannot resume campaign from current state' }, status: :unprocessable_entity
      end
    when "disable"
      if @campaign.aasm.current_state == :saved || @campaign.aasm.current_state == :pause
        if @campaign.disable_campaign!
          render json: @campaign
        else
          render json: { error: @campaign.errors.full_messages }, status: :unprocessable_entity
        end
      else
        render json: { error: 'Cannot disable campaign from current state' }, status: :unprocessable_entity
      end
    else
      render json: { error: 'Invalid status transition' }, status: :unprocessable_entity
    end
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
