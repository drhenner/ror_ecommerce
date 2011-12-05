# == Schema Information
#
# Table name: suppliers
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)     not null
#  email      :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Supplier < ActiveRecord::Base

  has_many :variant_suppliers
  has_many :variants,         :through => :variant_suppliers
  has_many :phones

  validates :name,        :presence => true,       :length => { :maximum => 255 }
  validates :email,       :format   => { :with => CustomValidators::Emails.email_validator },       :length => { :maximum => 255 }

  # paginated results from the admin Supplier grid
  #
  # @param [Optional params]
  # @return [ Array[Variant] ]
  def self.admin_grid(params = {})

    params[:page] ||= 1
    params[:rows] ||= SETTINGS[:admin_grid_rows]

    grid = Supplier
    #grid.includes(:product)
    grid = grid.where("suppliers.name = ?", params[:name])  if params[:name].present?
    grid = grid.where("suppliers.email = ?", params[:email])  if params[:email].present?
    grid = grid.order("#{params[:sidx]} #{params[:sord]}")
    grid.paginate({:page => params[:page].to_i,:per_page => params[:rows].to_i})
  end
end
