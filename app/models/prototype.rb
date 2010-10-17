class Prototype < ActiveRecord::Base
  
  has_many :products
  has_many :prototype_properties
  has_many :properties,          :through => :prototype_properties
  
  validates :name,    :presence => true
  
  accepts_nested_attributes_for :properties, :prototype_properties
  
  def self.admin_grid(params = {})
    
    params[:page] ||= 1
    params[:rows] ||= 25
    
    grid = Prototype
    grid = grid.where("active == ?",true)                    unless  params[:show_all].present? && 
                                                              params[:show_all] == 'true'
    grid = grid.where("prototypes.display_name = ?", params[:display_name])  if params[:display_name].present?
    grid = grid.order("#{params[:sidx]} #{params[:sord]}").paginate(:page => params[:page], :per_page => params[:rows])

  end
  
  def display_active
    active? ? 'True' : 'False'
  end
end
