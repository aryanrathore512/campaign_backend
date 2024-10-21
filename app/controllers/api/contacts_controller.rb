class Api::ContactsController < ApplicationController
	def index
		if params[:q].blank?
			contacts = Contact.page(params[:page]).per(params[:limit] || 10)
			total = Contact.count
		else
			q = Contact.ransack(params[:q])
			contacts = q.result.page(params[:page]).per(params[:limit] || 10)
			total = contacts.total_count
		end

		render json: { contacts: contacts, total: total }
	end
end
