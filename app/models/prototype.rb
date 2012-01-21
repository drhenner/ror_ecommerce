class Prototype < ActiveRecord::Base

  has_many :products
  has_many :prototype_properties
  has_many :properties,          :through => :prototype_properties

  validates :name,    :presence => true, :length => { :maximum => 255 }

  accepts_nested_attributes_for :properties, :prototype_properties

  # paginated results from the admin Prototype grid
  #
  # @param [Optional params]
  # @return [ Array[Prototype] ]
  def self.admin_grid(params = {})

    params[:page] ||= 1
    params[:rows] ||= 25

    grid = Prototype
    grid = grid.where("active = ?",true)                    unless  params[:show_all].present? &&
                                                              params[:show_all] == 'true'
    grid = grid.where("prototypes.name LIKE ?", "#{params[:name]}%")  if params[:name].present?
    grid

  end

  # 'True' if active 'False' otherwise in plain english
  #
  # @param [none]
  # @return [String] 'True' or 'False'
  def display_active
    active? ? 'True' : 'False'
  end
end
