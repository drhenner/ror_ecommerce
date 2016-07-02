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

class Supplier < ApplicationRecord

  has_many :variant_suppliers
  has_many :variants,         through: :variant_suppliers
  has_many :phones

  validates :name,        presence: true,       length: { maximum: 255 }
  validates :email,       format: { with: CustomValidators::Emails.email_validator },       :length => { :maximum => 255 }

  # paginated results from the admin Supplier grid
  #
  # @param [Optional params]
  # @return [ Array[Variant] ]
  def self.admin_grid(params = {})
    grid = Supplier
    #grid.includes(:product)
    grid = grid.where("suppliers.name LIKE ?", "#{params[:name]}%")   if params[:name].present?
    grid = grid.where("suppliers.email LIKE ?", "#{params[:email]}%") if params[:email].present?
    grid
  end
end
