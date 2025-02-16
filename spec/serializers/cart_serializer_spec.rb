require 'rails_helper'

RSpec.describe CartSerializer do
  describe '#serialize' do
    let(:cart) { create(:cart) }
    let(:product1) { create(:product, price: 10.0) }
    let(:product2) { create(:product, price: 20.0) }
    let!(:cart_item1) { create(:cart_item, cart: cart, product: product1, quantity: 2) }
    let!(:cart_item2) { create(:cart_item, cart: cart, product: product2, quantity: 1) }

    subject { described_class.new(cart).serialize }

    it 'serializes the cart correctly' do
      expect(subject).to include(
        id: cart.id,
        total_price: cart.total_price
      )
    end

    it 'serializes the products correctly' do
      expect(subject[:products]).to match_array([
        {
          id: product1.id,
          name: product1.name,
          quantity: 2,
          unit_price: "10.0",
          total_price: "20.0"
        },
        {
          id: product2.id,
          name: product2.name,
          quantity: 1,
          unit_price: "20.0",
          total_price: "20.0"
        }
      ])
    end
  end
end
