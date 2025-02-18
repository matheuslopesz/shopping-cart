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

      create_cart_item
      update_cart_total_price

      true
    rescue ActiveRecord::RecordInvalid => e
      add_error(e.message)

      false
    end

    private

    def valid?
      validator = ::CartItemValidator.new(params, cart)
      validator.valid?.tap { |valid| @errors = validator.errors unless valid }
    end

    def create_cart_item
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

    def update_cart_total_price
      cart.update!(total_price: cart.total_price)
    end

    def product
      @product ||= Product.find_by(id: params[:product_id])
    end

    def add_error(message)
      @errors << message
    end
  end
end
