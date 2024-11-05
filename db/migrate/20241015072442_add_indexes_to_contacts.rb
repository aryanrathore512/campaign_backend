class AddIndexesToContacts < ActiveRecord::Migration[7.0]
  def change
    add_index :contacts, :email, unique: true
  end
end
