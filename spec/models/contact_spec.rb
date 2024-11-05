require 'rails_helper'

RSpec.describe Contact, type: :model do
  describe '.ransackable_attributes' do
    it 'returns the ransackable attributes' do
      expect(Contact.ransackable_attributes).to match_array(
        ["id", "name", "address", "age", "email", "updated_at", "created_at"]
      )
    end
  end
end
