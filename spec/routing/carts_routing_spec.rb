require "rails_helper"

RSpec.describe CartsController, type: :routing do
  describe 'routes' do
    it 'routes to #show' do
      expect(get: '/carts/1').to route_to('carts#show', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/carts').to route_to('carts#create')
    end

    it 'routes to #add_item via PATCH' do
      expect(patch: '/carts/add_item').to route_to('carts#update')
    end

    it 'routes to #remove_item via DELETE' do
      expect(delete: '/carts/remove_item').to route_to('carts#remove_item')
    end
  end
end
