class CampaignMailer < ApplicationMailer
	default from: "noreply@gmail.com"

	def send_campaign_email(contact, campaign)
	    @contact = contact
	    @campaign = campaign
	    @greeting = "Hello #{@contact.name},"

	    mail(to: @contact.email, subject: @campaign.name)
	end
end
