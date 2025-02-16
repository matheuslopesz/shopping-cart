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
end
