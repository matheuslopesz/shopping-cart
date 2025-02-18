module CartItems
  class UpdateService
    attr_reader :cart, :params, :errors

    def initialize(cart, params)
      @cart = cart
      @params = params
      @errors = []
    end

    def run
      return false unless valid?

      update_cart_item
      recalculate_cart_total_price

      true
    rescue ActiveRecord::RecordInvalid => e
      add_error(e.message)
      false
    end

    private

    def valid?
      validator = CartItemValidator.new(params, cart)
      is_valid = validator.valid?

      @errors = validator.errors unless is_valid

      is_valid
    end

    def update_cart_item
      cart_item = cart.cart_items.find_by(product_id: params[:product_id])

      if cart_item
        cart_item.update!(quantity: cart_item.quantity + params[:quantity].to_i)
      else
        cart.cart_items.create!(
          product: product,
          quantity: params[:quantity]
        )
      end
    end

    def recalculate_cart_total_price
      cart.update!(total_price: cart.calculate_total_price)
    end

    def product
      @product ||= Product.find_by(id: params[:product_id])
    end

    def add_error(message)
      @errors << message
    end
  end
end
