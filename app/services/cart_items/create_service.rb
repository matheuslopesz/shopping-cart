module CartItems
  class CreateService
    attr_reader :cart, :params, :errors

    def initialize(cart, params)
      @cart = cart
      @params = params
      @errors = []
    end

    def run
      return false unless valid?

      create_or_update_cart_item
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

    def create_or_update_cart_item
      cart_item = find_or_initialize_cart_item
      cart_item.quantity += params[:quantity].to_i
      cart_item.save!
    end

    def find_or_initialize_cart_item
      cart.cart_items.find_or_initialize_by(product_id: params[:product_id]) do |item|
        item.product = product
        item.quantity = 0
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
