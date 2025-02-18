require 'rails_helper'

RSpec.describe CartItems::RemoveService do
  let(:cart) { create(:cart) }
  let(:product) { create(:product, name: "Test Product", price: 10.0) }
  let(:service) { described_class.new(cart, product.id) }

  describe '#run' do
    context 'when the product is in the cart with quantity > 1' do
      before do
        create(:cart_item, cart: cart, product: product, quantity: 2)
        cart.update!(total_price: cart.calculate_total_price)
      end

      it 'decrements the product quantity' do
        expect {
          service.run
        }.to change {
          cart.cart_items.find_by(product_id: product.id).quantity
        }.from(2).to(1)
      end

      it 'updates the cart total price' do
        expect {
          service.run
        }.to change {
          cart.reload.total_price
        }.from(20.0).to(10.0)
      end

      it 'returns true' do
        expect(service.run).to be true
      end
    end

    context 'when the product is in the cart with quantity = 1' do
      before do
        create(:cart_item, cart: cart, product: product, quantity: 1)
        cart.update!(total_price: cart.calculate_total_price)
      end

      it 'removes the product from the cart' do
        expect {
          service.run
        }.to change(CartItem, :count).by(-1)

        expect(cart.cart_items.find_by(product_id: product.id)).to be_nil
      end

      it 'updates the cart total price' do
        expect {
          service.run
        }.to change {
          cart.reload.total_price
        }.from(10.0).to(0)
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