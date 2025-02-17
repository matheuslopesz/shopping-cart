class CartsController < ApplicationController
  before_action :set_cart, only: [:show]

  def show
    serializer = CartSerializer.new(@cart)
    render json: serializer.serialize
  end

  def add_items
    @cart = Cart.find_or_create_by(id: session[:cart_id])
    session[:cart_id] = @cart.id

    service = CartItems::CreateService.new(@cart, cart_item_params)

    if service.run
      render json: CartSerializer.new(@cart.reload).serialize, status: :created
    else
      render json: { errors: service.errors }, status: :unprocessable_entity
    end
  end

  def update_item
    @cart = Cart.find_or_create_by(id: session[:cart_id])
    session[:cart_id] = @cart.id
  
    service = CartItems::UpdateService.new(@cart, cart_item_params)
  
    if service.run
      render json: CartSerializer.new(@cart.reload).serialize, status: :ok
    else
      render json: { errors: service.errors }, status: :unprocessable_entity
    end
  end

  private

  def set_cart
    @cart = Cart.find_by(id: params[:id])

    render json: { error: "Carrinho não encontrado" }, status: :not_found unless @cart
  end

  def cart_item_params
    params.permit(:product_id, :quantity)
  end
end