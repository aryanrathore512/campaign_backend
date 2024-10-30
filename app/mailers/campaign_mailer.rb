class CampaignMailer < ApplicationMailer
  default from: "noreply@gmail.com"

  def send_campaign_email(contact, template, campaign)
    @contact = contact
    @campaign = campaign
    @template = template
    @greeting = "Hello #{@contact.name},"

    email_body = dynamic_template_body(@template.body)

    mail(to: @contact.email, subject: 'Your Campaign Email') do |format|
      format.html { render html: email_body.html_safe }
    end
  end

  private

  def dynamic_template_body(body)
    body.gsub('{{name}}', @contact.name)
        .gsub('{{address}}', @contact.address || 'N/A')
  end
end
