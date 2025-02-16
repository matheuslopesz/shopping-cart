require 'rails_helper'

RSpec.describe CartItemValidator do
  let(:cart) { create(:cart) }
  let(:product) { create(:product) }
  let(:valid_params) { { product_id: product.id, quantity: 1 } }

  subject { described_class.new(params, cart) }

  describe '#valid?' do
    context 'when params are valid' do
      let(:params) { valid_params }

      it 'returns true' do
        expect(subject.valid?).to be true
      end

      it 'does not add any errors' do
        subject.valid?
        expect(subject.errors).to be_empty
      end
    end

    context 'when product_id is missing' do
      let(:params) { { quantity: 1 } }

      it 'returns false' do
        expect(subject.valid?).to be false
      end

      it 'adds a product_id error' do
        subject.valid?
        expect(subject.errors).to include('Product id is required')
      end
    end

    context 'when quantity is invalid' do
      let(:params) { { product_id: product.id, quantity: 0 } }

      it 'returns false' do
        expect(subject.valid?).to be false
      end

      it 'adds a quantity error' do
        subject.valid?
        expect(subject.errors).to include('Quantity must be greater than 0')
      end
    end

    context 'when product does not exist' do
      let(:params) { { product_id: 99999, quantity: 1 } }

      it 'returns false' do
        expect(subject.valid?).to be false
      end

      it 'adds a product not found error' do
        subject.valid?
        expect(subject.errors).to include('Product not found')
      end
    end

    context 'when product already present in cart' do
      before { create(:cart_item, cart: cart, product: product) }
      let(:params) { valid_params }

      it 'returns false' do
        expect(subject.valid?).to be false
      end

      it 'adds a product already exists error' do
        subject.valid?
        expect(subject.errors).to include('Product already present in cart')
      end
    end
  end
end
