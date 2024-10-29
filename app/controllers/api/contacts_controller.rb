class Api::ContactsController < ApplicationController
  def index
    if params[:select_all] == 'true'
      select_all_contacts
    else
      page = params[:page] || DEFAULT_PAGE
      limit = params[:limit] || DEFAULT_CONTACTS_PER_PAGE

      if params[:q].blank?
        contacts = Contact.page(page).per(limit)
        total = contacts.count
      else
        q = Contact.ransack(params[:q])
        contacts = q.result.page(page).per(limit)
        total = contacts.count
      end

      render json: { contacts: contacts, total: total }
    end
  end

  def selected_contacts
    contact_ids = params[:contact_ids].split(',').map(&:to_i)
    contacts = Contact.where(id: contact_ids)
    render json: { contacts: contacts }
  end

  private

  def select_all_contacts
    all_contact_ids = Contact.pluck(:id)
    render json: { all_contact_ids: all_contact_ids }, status: :ok
  end
end
