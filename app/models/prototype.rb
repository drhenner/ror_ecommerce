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
    grid = grid.where("prototypes.display_name = ?", params[:display_name])  if params[:display_name].present?
    grid = grid.order("#{params[:sidx]} #{params[:sord]}").paginate(:page => params[:page], :per_page => params[:rows])

  end

  # 'True' if active 'False' otherwise in plain english
  #
  # @param [none]
  # @return [String] 'True' or 'False'
  def display_active
    active? ? 'True' : 'False'
  end
end
