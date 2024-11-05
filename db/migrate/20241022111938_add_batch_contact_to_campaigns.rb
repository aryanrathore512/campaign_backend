class AddBatchContactToCampaigns < ActiveRecord::Migration[7.0]
  def change
    add_column :campaigns, :batch_contact, :integer
  end
end
