class RemoveLastRunTimeFromCampaigns < ActiveRecord::Migration[7.0]
  def change
    remove_column :campaigns, :last_run_time, :datetime
  end
end
