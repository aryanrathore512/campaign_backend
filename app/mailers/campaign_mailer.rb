class CampaignMailer < ApplicationMailer
  default from: "noreply@gmail.com"

  def send_campaign_email(contact, template, campaign)
    @contact = contact
    @campaign = campaign
    @template = template
    @greeting = "Hello #{@contact.name},"

    if @template.body.include?('{{name}}') || @template.body.include?('{{address}}')
      @body = @template.body.gsub("{{name}}", @contact.name).gsub("{{address}}", @contact.address)
    else
      @body = @template.body
    end

    mail(to: @contact.email, subject: @campaign.name)
  end
end
