module CartItems
  class RemoveService
    attr_reader :cart, :product_id, :errors

    def initialize(cart, product_id)
      @cart = cart
      @product_id = product_id
      @errors = []
    end

    def run
      return false unless valid?

      remove_or_decrement_cart_item
      update_cart_total_price

      true
    rescue ActiveRecord::RecordInvalid => e
      add_error(e.message)
      false
    end

    private

    def valid?
      if cart.cart_items.find_by(product_id: product_id).nil?
        add_error("Produto não encontrado no carrinho")
        false
      else
        true
      end
    end

    def remove_or_decrement_cart_item
      cart_item = cart.cart_items.find_by(product_id: product_id)

      if cart_item.quantity > 1
        cart_item.update!(quantity: cart_item.quantity - 1)
      else
        cart_item.destroy!
      end
    end

    def update_cart_total_price
      cart.update!(total_price: cart.calculate_total_price)
    end

    def add_error(message)
      @errors << message
    end
  end
end