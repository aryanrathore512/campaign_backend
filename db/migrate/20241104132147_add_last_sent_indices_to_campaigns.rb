class AddLastSentIndicesToCampaigns < ActiveRecord::Migration[7.0]
  def change
    add_column :campaigns, :last_sent_template_index, :integer, default: 0
    add_column :campaigns, :last_sent_contact_index, :integer, default: 0
  end
end
