class ProductType < ActiveRecord::Base
  acts_as_tree  :order => "name"
  has_many :products

  validates :name,    :presence => true

  def self.admin_grid(params = {})

    params[:page] ||= 1
    params[:rows] ||= SETTINGS[:admin_grid_rows]

    grid = ProductType
    grid = grid.where("product_types.name LIKE '?'", params[:name])              if params[:name].present?
    grid = grid.where("product_types.name LIKE '?%'", params[:name_starts_with]) if params[:name_starts_with].present?
    grid = grid.where("product_types.name LIKE '%?%'", params[:name_contains])   if params[:name_contains].present?
    grid.paginate({:page => params[:page],:per_page => params[:rows]})
  end

end
