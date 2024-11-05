require 'rails_helper'

RSpec.describe Api::ContactsController, type: :controller do
  describe 'GET #index' do
    let!(:contacts) { create_list(:contact, 30) }

    context 'when selecting all contacts' do
      it 'returns all contact IDs' do
        get :index, params: { select_all: 'true' }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['all_contact_ids']).to match_array(Contact.pluck(:id))
      end
    end

    context 'when paginating contacts' do
      it 'returns paginated contacts with a default limit' do
        get :index
        expect(response).to have_http_status(:ok)
        expect(response.status).to eq(200)
      end

      it 'returns paginated contacts with a custom limit' do
        get :index, params: { page: 1, limit: 10 }
        expect(response).to have_http_status(:ok)
        expect(response.status).to eq(200)
      end
    end

    context 'when searching with ransack' do
      let!(:matching_contact) { create(:contact, name: 'John Doe') }

      it 'returns contacts matching the search query' do
        get :index, params: { q: { name_cont: 'John' } }
        expect(response).to have_http_status(:ok)
        contacts_response = JSON.parse(response.body)['contacts']
        expect(contacts_response.size).to eq(1)
        expect(contacts_response.first['name']).to eq('John Doe')
      end

      it 'returns an empty result for non-matching queries' do
        get :index, params: { q: { name_cont: 'Nonexistent' } }
        expect(response).to have_http_status(:ok)
        contacts_response = JSON.parse(response.body)['contacts']
        expect(contacts_response.size).to eq(0)
      end
    end
  end

  describe 'GET #selected_contacts' do
    let!(:contacts) { create_list(:contact, 3) }

    it 'returns the selected contacts based on contact_ids' do
      contact_ids = contacts.map(&:id).join(',')
      get :selected_contacts, params: { contact_ids: contact_ids }
      expect(response).to have_http_status(:ok)
      selected_contacts = JSON.parse(response.body)['contacts']
      expect(selected_contacts.size).to eq(3)
      expect(selected_contacts.map { |c| c['id'] }).to match_array(contacts.map(&:id))
    end

    it 'returns an empty array if no contacts match the provided IDs' do
      get :selected_contacts, params: { contact_ids: '9999,10000' }
      expect(response).to have_http_status(:ok)
      selected_contacts = JSON.parse(response.body)['contacts']
      expect(selected_contacts.size).to eq(0)
    end
  end
end
