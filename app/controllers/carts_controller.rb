class CartsController < ApplicationController
  before_action :set_cart, only: [:show]

  def show
    serializer = CartSerializer.new(@cart)
    render json: serializer.serialize
  end

  private

  def set_cart
    @cart = Cart.find_by(id: params[:id])
    render json: { error: "Carrinho não encontrado" }, status: :not_found unless @cart
  end
end