class CartSerializer
  def initialize(cart)
    @cart = cart
  end

  def serialize
    {
      id: @cart.id,
      products: serialized_products,
      total_price: formatted_price(@cart.total_price)
    }
  end

  private

  def serialized_products
    @cart.cart_items.includes(:product).map { |item| serialize_product(item) }
  end

  def serialize_product(item)
    {
      id: item.product.id,
      name: item.product.name,
      quantity: item.quantity,
      unit_price: formatted_price(item.product.price),
      total_price: formatted_price(item_total_price(item))
    }
  end

  def item_total_price(item)
    item.product.price * item.quantity
  end

  def formatted_price(price)
    price.round(2)
  end
end
