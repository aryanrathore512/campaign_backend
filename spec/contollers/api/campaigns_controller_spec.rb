require 'rails_helper'

RSpec.describe Api::CampaignsController, type: :controller do
  let!(:campaign) { create(:campaign) }
  let!(:campaign_saved) { create(:campaign, status: 'saved') }
  let!(:campaign_paused) { create(:campaign, status: 'pause') }

  describe 'GET #index' do
    it 'returns a list of campaigns' do
      get :index
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)

      expect(json_response['all_campaigns'].size)
      expect(json_response['total_campaigns']).to eq(Campaign.count)
      expect(json_response['current_page']).to eq(1)
      expect(json_response['per_page']).to eq(10)
    end
  end

  describe 'GET #show' do
    it 'returns the requested campaign' do
      get :show, params: { id: campaign.id }
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)

      expect(json_response['id']).to eq(campaign.id)
      expect(json_response['name']).to eq(campaign.name)
    end

    it 'returns not found if campaign does not exist' do
      get :show, params: { id: 99999 }
      expect(response).to have_http_status(:not_found)
      json_response = JSON.parse(response.body)

      expect(json_response['error']).to eq('Campaign not found')
    end
  end

  describe 'POST #create' do
    let(:valid_attributes) { attributes_for(:campaign) }
    let(:template_ids) { create_list(:template, 3).map(&:id) }
    let(:contact_ids) { create_list(:contact, 3).map(&:id) }

    before do
      Campaign.destroy_all
    end

    it 'creates a new campaign with associated templates and contacts' do
      expect {
        post :create, params: {
          campaign: valid_attributes.merge(
            selectedTemplateIds: template_ids,
            selectedContactIds: contact_ids
          )
        }
      }.to change(Campaign, :count).by(1)

      expect(response).to have_http_status(:created)
      json_response = JSON.parse(response.body)

      expect(Campaign.count).to eq(1)
      expect(json_response['name']).to eq(valid_attributes[:name])

      expect(CampaignTemplate.count).to eq(template_ids.size)
      template_ids.each do |template_id|
        expect(CampaignTemplate.exists?(campaign_id: json_response['id'], template_id: template_id)).to be_truthy
      end

      expect(CampaignContact.count).to eq(contact_ids.size)
      contact_ids.each do |contact_id|
        expect(CampaignContact.exists?(campaign_id: json_response['id'], contact_id: contact_id)).to be_truthy
      end
    end
  end

  describe 'PATCH #update_status' do
    context 'when transitioning to saved' do
      it 'transitions from draft to saved' do
        patch :update_status, params: { id: campaign.id, status: 'saved' }
        expect(response).to have_http_status(:success)
        expect(campaign.reload.aasm.current_state.to_s).to eq('saved')
      end

      it 'returns unprocessable entity if not in draft state' do
        patch :update_status, params: { id: campaign_saved.id, status: 'saved' }
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)

        expect(json_response['error']).to eq('Cannot transition to saved from current state or already saved')
      end
    end

    context 'when pausing a campaign' do
      it 'transitions from saved to pause' do
        patch :update_status, params: { id: campaign_saved.id, status: 'pause' }
        expect(response).to have_http_status(:success)
        expect(campaign_saved.reload.aasm.current_state.to_s).to eq('pause')
      end

      it 'returns unprocessable entity if not in saved state' do
        patch :update_status, params: { id: campaign.id, status: 'pause' }
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)

        expect(json_response['error']).to eq('Cannot pause campaign from current state or already paused')
      end
    end

    context 'when resuming a campaign' do
      it 'transitions from pause to saved' do
        patch :update_status, params: { id: campaign_paused.id, status: 'resume' }
        expect(response).to have_http_status(:success)
        expect(campaign_paused.reload.aasm.current_state.to_s).to eq('saved')
      end

      it 'returns unprocessable entity if not in pause state' do
        patch :update_status, params: { id: campaign_saved.id, status: 'resume' }
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)

        expect(json_response['error']).to eq('Cannot resume campaign from current state')
      end
    end

    context 'when disabling a campaign' do
      it 'transitions from saved to disabled' do
        patch :update_status, params: { id: campaign_saved.id, status: 'disable' }
        expect(response).to have_http_status(:success)
        expect(campaign_saved.reload.aasm.current_state.to_s).to eq('disabled')
      end

      it 'returns unprocessable entity if not in saved or pause state' do
        patch :update_status, params: { id: campaign.id, status: 'disable' }
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)

        expect(json_response['error']).to eq('Cannot disable campaign from current state')
      end
    end
  end
end
