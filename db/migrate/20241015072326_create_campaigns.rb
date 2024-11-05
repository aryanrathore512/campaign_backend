class CreateCampaigns < ActiveRecord::Migration[7.0]
  def change
    create_table :campaigns do |t|
      t.string :name
      t.string :campaign_type
      t.boolean :status
      t.integer :email_limit
      t.datetime :start_time
      t.datetime :end_time
      t.integer :campaign_run_time

      t.timestamps
    end
  end
end
