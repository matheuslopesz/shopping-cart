class CartItemValidator
  attr_reader :params, :cart, :errors

  def initialize(params, cart)
    @params = params
    @cart = cart
    @errors = []
  end

  def valid?
    validate_product_id
    validate_quantity
    validate_product

    errors.empty?
  end

  private

  def validate_product_id
    add_error(I18n.t('cart_item_validator.errors.product_id_required')) if params[:product_id].blank?
  end

  def validate_quantity
    add_error(I18n.t('cart_item_validator.errors.invalid_quantity')) if invalid_quantity?
  end

  def validate_product
    add_error(I18n.t('cart_item_validator.errors.product_not_found')) unless product
  end

  def invalid_quantity?
    params[:quantity].to_i <= 0
  end

  def product
    @product ||= Product.find_by(id: params[:product_id])
  end

  def add_error(message)
    @errors << message
  end
end
