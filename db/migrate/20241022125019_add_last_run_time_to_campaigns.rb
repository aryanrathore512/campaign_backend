class AddLastRunTimeToCampaigns < ActiveRecord::Migration[7.0]
  def change
    add_column :campaigns, :last_run_time, :datetime
  end
end
