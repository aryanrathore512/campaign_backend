class DropCampaignSentEmailsTable < ActiveRecord::Migration[7.0]
  def up
    drop_table :campaign_sent_emails
  end

  def down
    create_table :campaign_sent_emails do |t|
      t.references :campaign, null: false, foreign_key: true
      t.references :contact, null: false, foreign_key: true

      t.timestamps
    end
  end
end
