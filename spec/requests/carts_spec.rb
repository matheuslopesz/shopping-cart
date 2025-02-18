require 'rails_helper'

RSpec.describe '/carts', type: :request do
  describe 'GET /cart/:id' do
    let(:cart) { create(:cart) }

    context 'when the cart exists' do
      it 'returns the cart details' do
        get "/carts/#{cart.id}"
  
        expect(response).to have_http_status(:ok)
        expect(json_response).to include('id' => cart.id)
      end
    end
  
    context 'when the cart does not exist' do
      it 'returns a not found error' do
        get '/carts/999'
  
        expect(response).to have_http_status(:not_found)
        expect(json_response).to include('error' => 'Carrinho não encontrado')
      end
    end
  end

  describe 'POST /carts' do
    let(:product) { create(:product, name: 'Test Product', price: 10.0) }
    let(:valid_params) { { product_id: product.id, quantity: 1 } }
  
    context 'with valid params' do
      it 'creates a new cart and adds the item' do
        post '/carts', params: valid_params
  
        expect(response).to have_http_status(:created)
        expect(json_response).to include(
          'id' => be_present,
          'products' => [
            {
              'id' => product.id,
              'name' => 'Test Product',
              'quantity' => 1,
              'unit_price' => 10.00,
              'total_price' => 10.00
            }
          ],
          'total_price' => 10.00
        )
      end
  
      context 'with multiple items' do
        let(:product2) { create(:product, name: 'Test Product 2', price: 20.0) }
        let(:valid_params2) { { product_id: product2.id, quantity: 2 } }
  
        it 'adds multiple items to the cart' do
          post '/carts', params: valid_params
          post '/carts', params: valid_params2
  
          expect(response).to have_http_status(:created)
          expect(json_response['products'].size).to eq(2)
          expect(json_response['total_price']).to eq(50.00)
        end
      end
  
      context 'when the product is already in the cart' do
        it 'increments the product quantity' do
          post '/carts', params: valid_params
          post '/carts', params: valid_params
  
          expect(response).to have_http_status(:created)
          expect(json_response['products'].size).to eq(1)
          expect(json_response['products'].first['quantity']).to eq(2)
          expect(json_response['total_price']).to eq(20.00)
        end
      end
    end
  
    context 'with invalid params' do
      context 'with missing product_id' do
        let(:invalid_params) { { quantity: 1 } }
  
        it 'returns an error' do
          post '/carts', params: invalid_params
  
          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response['errors']).to include('Product id is required', 'Product not found')
        end
      end
  
      context 'with invalid quantity' do
        let(:invalid_params) { { product_id: product.id, quantity: 0 } }
  
        it 'returns an error' do
          post '/carts', params: invalid_params
  
          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response['errors']).to include('Quantity must be greater than 0')
        end
      end
  
      context 'with non-existent product' do
        let(:invalid_params) { { product_id: 999_999, quantity: 1 } }
  
        it 'returns an error' do
          post '/carts', params: invalid_params
  
          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response['errors']).to include('Product not found')
        end
      end
    end  
  end

  describe 'PATCH /carts/add_item' do
    let(:cart) { create(:cart) }
    let(:product) { create(:product, name: 'Test Product', price: 10.0) }
    let(:valid_params) { { product_id: product.id, quantity: 2, cart_id: cart.id } }

    context 'when the product is already in the cart' do
      before do
        cart.cart_items.create(product: product, quantity: 1)
      end

      it 'updates the product quantity' do
        patch '/carts/add_item', params: valid_params

        expect(response).to have_http_status(:ok)
        expect(json_response).to include(
          'products' => [
            {
              'id' => product.id,
              'name' => 'Test Product',
              'quantity' => 3,
              'unit_price' => 10.00,
              'total_price' => 30.00
            }
          ],
          'total_price' => 30.00
        )
      end
    end

    context 'when the product is not in the cart' do
      it 'adds the product to the cart' do
        patch '/carts/add_item', params: valid_params

        expect(response).to have_http_status(:ok)
        expect(json_response).to include(
          'products' => [
            {
              'id' => product.id,
              'name' => product.name,
              'quantity' => 2,
              'unit_price' => 10.00,
              'total_price' => 20.00
            }
          ],
          'total_price' => 20.00
        )
      end
    end

    context 'with invalid params' do
      context 'with missing product_id' do
        let(:invalid_params) { { quantity: 2 } }

        it 'returns an error' do
          patch '/carts/add_item', params: invalid_params

          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response['errors']).to include('Product id is required', 'Product not found')
        end
      end

      context 'with invalid quantity' do
        let(:invalid_params) { { product_id: product.id, quantity: 0 } }

        it 'returns an error' do
          patch '/carts/add_item', params: invalid_params

          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response['errors']).to include('Quantity must be greater than 0')
        end
      end

      context 'with non-existent product' do
        let(:invalid_params) { { product_id: 999_999, quantity: 2 } }

        it 'returns an error' do
          patch '/carts/add_item', params: invalid_params

          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response['errors']).to include('Product not found')
        end
      end
    end
  end

  describe 'DELETE /carts/remove_item' do
    let(:cart) { create(:cart) }
    let(:product) { create(:product, price: 10.0) }

    context 'when the product is in the cart' do
      before do
        cart.cart_items.create(product: product, quantity: 2)
        cart.update!(total_price: cart.calculate_total_price)
      end

      it 'removes the product from the cart' do
        delete "/carts/remove_item", params: { product_id: product.id, cart_id: cart.id }

        expect(response).to have_http_status(:ok)
        expect(json_response['products'].size).to eq(1) # já que apenas um foi removido
        expect(json_response['total_price']).to eq(10)
      end

      it 'updates the cart total price' do
        expect {
          delete "/carts/remove_item", params: { product_id: product.id, cart_id: cart.id }
        }.to change {
          cart.reload.total_price
        }.from(20.00).to(10.00)
      end
    end

    context 'when the product is not in the cart' do
      it 'returns an error' do
        delete "/carts/remove_item", params: { product_id: 999, cart_id: cart.id }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['errors']).to include('Produto não encontrado no carrinho')
      end

      it 'does not change the cart items count' do
        expect {
          delete "/carts/remove_item", params: { product_id: 999, cart_id: cart.id }
        }.not_to change(CartItem, :count)
      end
    end

    context 'when the cart does not exist' do
      it 'returns an error' do
        delete "/carts/remove_item", params: { product_id: product.id, cart_id: 999 }

        expect(response).to have_http_status(:not_found)
        expect(json_response['error']).to eq('Carrinho não encontrado')
      end

      it 'does not change the cart items count' do
        expect {
          delete "/carts/remove_item", params: { product_id: product.id, cart_id: 999 }
        }.not_to change(CartItem, :count)
      end
    end

    context 'when the product is in the cart with quantity > 1' do
      before do
        cart.cart_items.create(product: product, quantity: 3)
        cart.update!(total_price: cart.calculate_total_price) # Atualiza o total_price
      end

      it 'decrements the product quantity' do
        delete "/carts/remove_item", params: { product_id: product.id, cart_id: cart.id }

        expect(response).to have_http_status(:ok)
        expect(json_response['products'].first['quantity']).to eq(2)
        expect(json_response['total_price']).to eq(20.0)
      end

      it 'updates the cart total price' do
        expect {
          delete "/carts/remove_item", params: { product_id: product.id, cart_id: cart.id }
        }.to change {
          cart.reload.total_price
        }.from(30.0).to(20.0)
      end
    end
  end

  private

  def json_response
    JSON.parse(response.body)
  end
end