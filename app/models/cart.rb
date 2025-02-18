class Cart < ApplicationRecord
  has_many :products, through: :cart_items
  has_many :cart_items, dependent: :destroy

  validates :total_price, numericality: { greater_than_or_equal_to: 0 }

  def calculate_total_price
    cart_items.sum(&:calculate_total_price)
  end
end
