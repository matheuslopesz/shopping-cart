require 'rails_helper'

RSpec.describe ManageAbandonedCartsJob, type: :job do
  describe '#perform' do
    let!(:active_cart) { create(:cart, last_interaction_at: 2.hours.ago, abandoned: false) }
    let!(:abandoned_cart) { create(:cart, last_interaction_at: 4.hours.ago, abandoned: false) }
    let!(:old_abandoned_cart) { create(:cart, last_interaction_at: 8.days.ago, abandoned: true) }

    it 'marks carts as abandoned if inactive for 3 hours' do
      expect {
        ManageAbandonedCartsJob.perform_now
      }.to change { abandoned_cart.reload.abandoned? }.from(false).to(true)
    end

    it 'does not mark active carts as abandoned' do
      expect {
        ManageAbandonedCartsJob.perform_now
      }.not_to change { active_cart.reload.abandoned? }
    end

    it 'removes carts abandoned for more than 7 days' do
      expect {
        ManageAbandonedCartsJob.perform_now
      }.to change { Cart.count }.by(-1)
    end

    it 'does not remove recently abandoned carts' do
      recently_abandoned_cart = create(:cart, last_interaction_at: 6.days.ago, abandoned: true)
      expect {
        ManageAbandonedCartsJob.perform_now
      }.not_to change { recently_abandoned_cart.reload.persisted? }
    end
  end
end