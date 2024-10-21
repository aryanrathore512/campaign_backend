class Api::TemplatesController < ApplicationController
  before_action :find_template, only: [:update]

  def index
    @templates = Template.page(params[:page]).per(params[:per_page] || 10)
    render json: @templates
  end

  def create
    @template = Template.new(template_params)

    if @template.save
      render json: @template, status: :created
    else
      render json: @template.errors.full_messages, status: :unprocessable_entity
    end
  end

  def update
    if @template.update(template_params)
      render json: @template, status: :ok
    else
      render json: { errors: @template.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def template_params
    params.require(:template).permit(:title, :body)
  end

  def find_template
    @template = Template.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Template not found' }, status: :not_found
  end
end
