class ChangeStatusInCampaigns < ActiveRecord::Migration[7.0]
  def change
    change_column :campaigns, :status, :string
  end
end
