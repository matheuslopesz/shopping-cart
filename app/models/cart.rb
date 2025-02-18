class Cart < ApplicationRecord
  has_many :products, through: :cart_items
  has_many :cart_items, dependent: :destroy

  def calculate_total_price
    cart_items.sum(&:total_price)
  end
end
