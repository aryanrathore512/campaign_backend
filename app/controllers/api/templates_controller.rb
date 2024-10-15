class Api::TemplatesController < ApplicationController
	def index
		@templats = Template.all
		render json: @templats
	end

	def create
		@template = Template.new(template_params)
		if @template.save
			render json: @template, status: :created
		else
			render json: template.errors, status: :unprocessable_entity
		end
	end

	private

	def template_params
		params.permit(:title, :body)
	end
end
