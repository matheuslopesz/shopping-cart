require 'rails_helper'

RSpec.describe "/carts", type: :request do
  describe "GET /cart/:id" do
    let(:cart) { create(:cart) }

    it "returns the cart details" do
      get "/carts/#{cart.id}"
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to include("id" => cart.id)
    end

    it "returns a not found error if the cart does not exist" do
      get "/carts/999"

      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)).to include("error" => "Carrinho não encontrado")
    end
  end

  describe "POST /add_items" do
    let(:product) { create(:product, name: "Test Product", price: 10.0) }
    let(:valid_params) { { product_id: product.id, quantity: 1 } }

    context "with valid params" do
      it "creates a new cart and adds the item" do
        post '/carts/add_items', params: valid_params

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)).to include(
          "id" => be_present,
          "products" => [
            {
              "id" => product.id,
              "name" => product.name,
              "quantity" => 1,
              "unit_price" => product.price.to_s,
              "total_price" => (product.price * 1).to_s
            }
          ],
          "total_price" => (product.price * 1).to_s
        )
      end

      context "with multiple items" do
        let(:product2) { create(:product, name: "Test Product 2", price: 20.0) }
        let(:valid_params) { { product_id: product.id, quantity: 1 } }
        let(:valid_params2) { { product_id: product2.id, quantity: 2 } }

        it "adds multiple items to the cart" do
          post '/carts/add_items', params: valid_params
          post '/carts/add_items', params: valid_params2

          expect(response).to have_http_status(:created)
          cart_response = JSON.parse(response.body)
          expect(cart_response["products"].size).to eq(2)
          expect(cart_response["total_price"]).to eq((product.price * 1 + product2.price * 2).to_s)
        end
      end

      context 'when the product already is in the cart' do
        it 'increments the product quantity' do
          post '/carts/add_items', params: valid_params
          post '/carts/add_items', params: valid_params

          expect(response).to have_http_status(:created)
          cart_response = JSON.parse(response.body)
          expect(cart_response["products"].size).to eq(1)
          expect(cart_response["products"].first["quantity"]).to eq(2)
        end
      end
    end

    context "with invalid params" do
      context "with missing product_id" do
        let(:invalid_params) { { quantity: 1 } }

        it "returns an error" do
          post '/carts/add_items', params: invalid_params

          expect(response).to have_http_status(:unprocessable_entity)
          expect(JSON.parse(response.body)).to include("errors" => ["Product id is required", "Product not found"])
        end
      end

      context "with invalid quantity" do
        let(:invalid_params) { { product_id: product.id, quantity: 0 } }

        it "returns an error" do
          post '/carts/add_items', params: invalid_params

          expect(response).to have_http_status(:unprocessable_entity)
          expect(JSON.parse(response.body)).to include("errors" => ["Quantity must be greater than 0"])
        end
      end

      context "with non-existent product" do
        let(:invalid_params) { { product_id: 999999, quantity: 1 } }

        it "returns an error" do
          post '/carts/add_items', params: invalid_params

          expect(response).to have_http_status(:unprocessable_entity)
          expect(JSON.parse(response.body)).to include("errors" => ["Product not found"])
        end
      end
    end
  end

  describe "PATCH /update_item" do
    let(:cart) { create(:cart) }
    let(:product) { create(:product, name: "Test Product", price: 10.0) }
    let(:valid_params) { { product_id: product.id, quantity: 2 } }

    context "when the product is already in the cart" do
      before do
        cart.cart_items.create(product: product, quantity: 1)
      end

      it "updates the product quantity" do
        patch '/carts/update_item', params: valid_params

        expect(response).to have_http_status(:ok)
        cart_response = JSON.parse(response.body)
        expect(cart_response["products"].size).to eq(1)
        expect(cart_response["products"].first["quantity"]).to eq(2)
        expect(cart_response["total_price"]).to eq((product.price * 2).to_s)
      end
    end

    context "when the product is not in the cart" do
      it "adds the product to the cart" do
        patch '/carts/update_item', params: valid_params

        expect(response).to have_http_status(:ok)
        cart_response = JSON.parse(response.body)
        expect(cart_response["products"].size).to eq(1)
        expect(cart_response["products"].first["quantity"]).to eq(2)
        expect(cart_response["total_price"]).to eq((product.price * 2).to_s)
      end
    end

    context "with invalid params" do
      context "with missing product_id" do
        let(:invalid_params) { { quantity: 2 } }

        it "returns an error" do
          patch '/carts/update_item', params: invalid_params

          expect(response).to have_http_status(:unprocessable_entity)
          expect(JSON.parse(response.body)).to include("errors" => ["Product id is required", "Product not found"])
        end
      end

      context "with invalid quantity" do
        let(:invalid_params) { { product_id: product.id, quantity: 0 } }

        it "returns an error" do
          patch '/carts/update_item', params: invalid_params

          expect(response).to have_http_status(:unprocessable_entity)
          expect(JSON.parse(response.body)).to include("errors" => ["Quantity must be greater than 0"])
        end
      end

      context "with non-existent product" do
        let(:invalid_params) { { product_id: 999999, quantity: 2 } }

        it "returns an error" do
          patch '/carts/update_item', params: invalid_params

          expect(response).to have_http_status(:unprocessable_entity)
          expect(JSON.parse(response.body)).to include("errors" => ["Product not found"])
        end
      end
    end
  end
end