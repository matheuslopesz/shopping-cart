require 'rails_helper'

RSpec.describe Cart, type: :model do
  context 'when validating' do
    it 'validates numericality of total_price' do
      cart = described_class.new(total_price: -1)
      expect(cart.valid?).to be_falsey
      expect(cart.errors[:total_price]).to include("must be greater than or equal to 0")
    end
  end

  describe '#abandoned?' do
    let(:cart) { create(:cart) }

    it 'returns true if the cart has been inactive for more than 3 hours' do
      cart.update(last_interaction_at: 4.hours.ago)
      expect(cart.abandoned?).to be true
    end

    it 'returns false if the cart has been active within 3 hours' do
      cart.update(last_interaction_at: 2.hours.ago)
      expect(cart.abandoned?).to be false
    end
  end

  describe 'remove_if_abandoned' do
    let(:cart) { create(:cart, last_interaction_at: 7.days.ago) }

    it 'removes the shopping cart if abandoned for a certain time' do
      cart.remove_if_abandoned
      expect(Cart.count).to eq(0)
    end
  end
end
