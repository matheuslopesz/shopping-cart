require 'rails_helper'

RSpec.describe "/carts", type: :request do
  describe "GET /carts/:id" do
    let(:cart) { create(:cart) }

    it "returns the cart details" do
      get cart_path(cart.id)

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to include("id" => cart.id)
    end

    it "returns a not found error if the cart does not exist" do
      get cart_path(999)

      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)).to include("error" => "Carrinho não encontrado")
    end
  end

  describe "POST /add_items" do
    let(:cart) { Cart.create }
    let(:product) { Product.create(name: "Test Product", price: 10.0) }
    let!(:cart_item) { CartItem.create(cart: cart, product: product, quantity: 1) }

    context 'when the product already is in the cart' do
      subject do
        post '/cart/add_items', params: { product_id: product.id, quantity: 1 }, as: :json
        post '/cart/add_items', params: { product_id: product.id, quantity: 1 }, as: :json
      end

      it 'updates the quantity of the existing item in the cart' do
        expect { subject }.to change { cart_item.reload.quantity }.by(2)
      end
    end
  end
end
