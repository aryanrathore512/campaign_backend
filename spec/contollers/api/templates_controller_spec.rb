require 'rails_helper'

RSpec.describe Api::TemplatesController, type: :controller do
  let!(:template) { create(:template) }
  let(:valid_attributes) { { template: { title: 'New Template', body: 'This is a new template body.' } } }
  let(:invalid_attributes) { { template: { title: '', body: 'This body should not be empty.' } } }

  describe 'GET #index' do
    it 'returns a list of templates' do
      get :index
      expect(response).to have_http_status(:success)
      parsed_response = JSON.parse(response.body)
      expect(parsed_response.size).to eq(1)
      expect(parsed_response.first['title']).to eq(template.title)
    end
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      it 'creates a new template' do
        expect {
          post :create, params: valid_attributes
        }.to change(Template, :count).by(1)

        expect(response).to have_http_status(:created)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['title']).to eq('New Template')
      end
    end

    context 'with invalid attributes' do
      it 'does not create a new template' do
        expect {
          post :create, params: invalid_attributes
        }.not_to change(Template, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response.first).to include("Title Template title is required")
      end
    end
  end

  describe 'PATCH #update' do
    context 'with valid attributes' do
      it 'updates the template' do
        patch :update, params: { id: template.id, template: { title: 'Updated Title' } }
        expect(response).to have_http_status(:ok)
        template.reload
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['title']).to eq('Updated Title')
      end
    end

    context 'with invalid attributes' do
      it 'does not update the template' do
        patch :update, params: { id: template.id, template: invalid_attributes[:template] }
        expect(response).to have_http_status(:unprocessable_entity)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response["errors"].first).to include("Title Template title is required")
      end
    end

    context 'when the template does not exist' do
      it 'returns a not found error' do
        patch :update, params: { id: -1, template: { title: 'New Title' } }
        expect(response).to have_http_status(:not_found)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['error']).to eq('Template not found')
      end
    end
  end
end
