class ProductsController < ApplicationController

  def index
    products = Product.active.includes(:images, :active_variants)

    product_types = nil
    if params[:product_type_id].present? && product_type = ProductType.find_by_id(params[:product_type_id])
      product_types = product_type.self_and_descendants.map(&:id)
    end
    if product_types
      @products = products.where(product_type_id: product_types).
                           paginate(page: pagination_page, per_page: pagination_rows)
    else
      @products = products.paginate(page: pagination_page, per_page: pagination_rows)
    end
  end

  def create
    if params[:q].present?
      query = params[:q].to_s.truncate(200, omission: "")
      @products = Product.standard_search(query, page: pagination_page, per_page: pagination_rows)
    else
      @products = Product.active.includes(:images, :active_variants).paginate(page: pagination_page, per_page: pagination_rows)
    end

    render template: '/products/index'
  end

  def show
    @product = Product.friendly.active
                .includes(:images, active_variants: :variant_properties)
                .find(params[:id])
    form_info
    @cart_item.variant_id = @product.active_variants.first.try(:id)
  end

  private

  def form_info
    @cart_item = CartItem.new
  end

  def featured_product_types
    [ProductType::FEATURED_TYPE_ID]
  end

  def pagination_rows
    [(params[:rows] || 60).to_i, 100].min
  end
end
