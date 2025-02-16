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
      cart.cart_items.create!(
        product: product,
        quantity: params[:quantity]
      )
    end

    def product
      @product ||= Product.find_by(id: params[:product_id])
    end

    def add_error(message)
      @errors << message
    end
  end
end
