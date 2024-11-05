class CreateCampaignSentEmails < ActiveRecord::Migration[7.0]
  def change
    create_table :campaign_sent_emails do |t|
      t.references :campaign, null: false, foreign_key: true
      t.references :contact, null: false, foreign_key: true

      t.timestamps
    end
  end
end
