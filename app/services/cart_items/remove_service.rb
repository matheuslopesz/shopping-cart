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
      recalculate_cart_total_price
      update_last_interaction

      true
    rescue ActiveRecord::RecordInvalid => e
      add_error(e.message)
      false
    end

    private

    def valid?
      if cart.cart_items.find_by(product_id: product_id).nil?
        add_error(I18n.t('cart.errors.product_not_found_in_cart'))
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

    def recalculate_cart_total_price
      cart.update!(total_price: cart.calculate_total_price)
    end

    def add_error(message)
      @errors << message
    end

    def update_last_interaction
      cart.update!(last_interaction_at: Time.current)
    end
  end
end
