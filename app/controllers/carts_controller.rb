class CartsController < ApplicationController
  before_action :set_cart, only: [:show, :update, :remove_item]

  def show
    render_cart
  end

  def create
    @cart = Cart.find_or_create_by(id: session[:cart_id])
    session[:cart_id] = @cart.id

    service = CartItems::CreateService.new(@cart, cart_item_params)

    handle_service_response(service, :created)
  end

  def update
    service = CartItems::UpdateService.new(@cart, cart_item_params)
    handle_service_response(service)
  end

  def remove_item
    service = CartItems::RemoveService.new(@cart, params[:product_id])
    handle_service_response(service)
  end

  private

  def set_cart
    @cart = Cart.find_by(id: session[:cart_id])
    render_not_found(I18n.t('cart.errors.not_found')) unless @cart
  end

  def cart_item_params
    params.permit(:product_id, :quantity)
  end

  def handle_service_response(service, success_status = :ok)
    if service.run
      render_cart(success_status)
    else
      render_unprocessable_entity(service.errors)
    end
  end

  def render_cart(status = :ok)
    serializer = CartSerializer.new(@cart.reload)
    render json: serializer.serialize, status: status
  end

  def render_not_found(message)
    render json: { error: message }, status: :not_found
  end

  def render_unprocessable_entity(errors)
    render json: { errors: errors }, status: :unprocessable_entity
  end
end