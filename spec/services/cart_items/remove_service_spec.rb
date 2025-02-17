require 'rails_helper'

RSpec.describe CartItems::RemoveService do
  let(:cart) { create(:cart) }
  let(:product) { create(:product, name: "Test Product", price: 10.0) }
  let(:service) { described_class.new(cart, product.id) }

  describe '#run' do
    context 'when the product is in the cart' do
      before do
        create(:cart_item, cart: cart, product: product, quantity: 1)
      end

      it 'removes the product from the cart' do
        expect {
          service.run
        }.to change(CartItem, :count).by(-1)

        expect(cart.cart_items.find_by(product_id: product.id)).to be_nil
      end

      it 'returns true' do
        expect(service.run).to be true
      end
    end

    context 'when the product is not in the cart' do
      it 'returns false' do
        expect(service.run).to be false
      end

      it 'adds error message' do
        service.run
        expect(service.errors).to include('Produto não encontrado no carrinho')
      end

      it 'does not change the cart items count' do
        expect {
          service.run
        }.not_to change(CartItem, :count)
      end
    end

    context 'when the cart is empty' do
      it 'returns false' do
        expect(service.run).to be false
      end

      it 'adds error message' do
        service.run
        expect(service.errors).to include('Produto não encontrado no carrinho')
      end

      it 'does not change the cart items count' do
        expect {
          service.run
        }.not_to change(CartItem, :count)
      end
    end
  end
end