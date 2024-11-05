class AddIntervalAfterFirstTemplateToCampaigns < ActiveRecord::Migration[7.0]
  def change
    add_column :campaigns, :interval_after_first_template, :integer
  end
end
