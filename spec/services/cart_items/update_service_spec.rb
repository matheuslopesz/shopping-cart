require 'rails_helper'

RSpec.describe CartItems::UpdateService do
  let(:cart) { create(:cart) }
  let(:product) { create(:product, name: "Test Product", price: 10.0) }
  let(:valid_params) { { product_id: product.id, quantity: 2 } }
  let(:service) { described_class.new(cart, valid_params) }

  describe '#run' do
    context 'with valid params' do
      context 'when the product is already in the cart' do
        before do
          create(:cart_item, cart: cart, product: product, quantity: 1)
        end

        it 'updates the product quantity' do
          expect {
            service.run
          }.not_to change(CartItem, :count)

          cart_item = cart.cart_items.find_by(product_id: product.id)
          expect(cart_item.quantity).to eq(3)
        end

        it 'returns true' do
          expect(service.run).to be true
        end
      end

      context 'when the product is not in the cart' do
        it 'adds the product to the cart' do
          expect {
            service.run
          }.to change(CartItem, :count).by(1)

          cart_item = cart.cart_items.last
          expect(cart_item.product).to eq(product)
          expect(cart_item.quantity).to eq(2)
        end

        it 'returns true' do
          expect(service.run).to be true
        end
      end
    end

    context 'with invalid params' do
      context 'with missing product_id' do
        let(:invalid_params) { { quantity: 2 } }
        let(:service) { described_class.new(cart, invalid_params) }

        it 'returns false' do
          expect(service.run).to be false
        end

        it 'adds error message' do
          service.run
          expect(service.errors).to include('Product id is required')
        end

        it 'does not create or update cart item' do
          expect {
            service.run
          }.not_to change(CartItem, :count)
        end
      end

      context 'with invalid quantity' do
        let(:invalid_params) { { product_id: product.id, quantity: 0 } }
        let(:service) { described_class.new(cart, invalid_params) }

        it 'returns false' do
          expect(service.run).to be false
        end

        it 'adds error message' do
          service.run
          expect(service.errors).to include('Quantity must be greater than 0')
        end

        it 'does not create or update cart item' do
          expect {
            service.run
          }.not_to change(CartItem, :count)
        end
      end

      context 'with non-existent product' do
        let(:invalid_params) { { product_id: 999999, quantity: 2 } }
        let(:service) { described_class.new(cart, invalid_params) }

        it 'returns false' do
          expect(service.run).to be false
        end

        it 'adds error message' do
          service.run
          expect(service.errors).to include('Product not found')
        end

        it 'does not create or update cart item' do
          expect {
            service.run
          }.not_to change(CartItem, :count)
        end
      end
    end
  end
end