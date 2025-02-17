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

      remove_cart_item
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

    def remove_cart_item
      cart_item = cart.cart_items.find_by(product_id: product_id)
      cart_item.destroy!
    end

    def add_error(message)
      @errors << message
    end
  end
end