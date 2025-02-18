class ManageAbandonedCartsJob < ApplicationJob
  queue_as :default

  def perform
    mark_abandoned_carts
    remove_abandoned_carts
  end

  private

  def mark_abandoned_carts
    carts = Cart.where('last_interaction_at <= ?', 3.hours.ago).where(abandoned: false)
    carts.find_each do |cart|
      cart.mark_as_abandoned
    end
  end

  def remove_abandoned_carts
    carts_to_remove = Cart.where('last_interaction_at < ?', 7.days.ago).where(abandoned: true)
    carts_to_remove.each(&:remove_if_abandoned)
  end
end