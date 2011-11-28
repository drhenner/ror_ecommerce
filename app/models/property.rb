class Property < ActiveRecord::Base

  has_many :prototype_properties
  has_many :prototypes,          :through => :prototype_properties

  has_many :product_properties
  has_many :products,          :through => :product_properties

  has_many :variant_properties
  has_many :variants,          :through => :variant_properties

  validates :identifing_name,    :presence => true, :length => { :maximum => 250 }
  validates :display_name,       :presence => true, :length => { :maximum => 165 }
  # active is default true at the DB level

  scope :visible, where("active == ?",true)


  def full_name
    "#{display_name}: (#{identifing_name})"
  end
  # paginated results from the admin Property grid
  #
  # @param [Optional params]
  # @return [ Array[Property] ]
  def self.admin_grid(params = {})

    params[:page] ||= 1
    params[:rows] ||= 25

    grid = Property
    grid = grid.where("active = ?",true)                    unless  params[:show_all].present? &&
                                                              params[:show_all] == 'true'
    grid = grid.where("properties.display_name = ?", params[:display_name])  if params[:display_name].present?
    grid.order("#{params[:sidx]} #{params[:sord]}").paginate(:page => params[:page].to_i, :per_page => params[:rows].to_i)

  end

  # 'True' if active 'False' otherwise in plain english
  #
  # @param [none]
  # @return [String] 'True' or 'False'
  def display_active
    active? ? 'True' : 'False'
  end

end
