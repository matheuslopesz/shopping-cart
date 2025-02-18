class Cart < ApplicationRecord
  ABANDONMENT_THRESHOLD = 2.hours

  has_many :products, through: :cart_items
  has_many :cart_items, dependent: :destroy

  validates :total_price, numericality: { greater_than_or_equal_to: 0 }

  def calculate_total_price
    cart_items.sum(&:calculate_total_price)
  end

  def abandoned?
    last_interaction_at < 3.hours.ago
  end

  def remove_if_abandoned
    destroy if last_interaction_at < 7.days.ago
  end
end
