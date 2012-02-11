class TaxStatus < ActiveRecord::Base
  has_many :products
  has_many :tax_rates

  before_destroy :check_products, :check_tax_rates

  #FOOD = 'Food'
  CLOTHES   = 'Clothes'
  COSMETICS = 'Cosmetics'
  STANDARD  = 'Standard'
  FOOD      = 'Food'

  STATUSES = [CLOTHES, COSMETICS, STANDARD, FOOD]

  CLOTHES_ID    = 1
  COSMETICS_ID  = 2
  STANDARD_ID   = 3
  FOOD_ID       = 4

  validates :name, :presence => true, :uniqueness => true,       :length => { :maximum => 255 }

  protected

  def check_products
    self.products.count == 0
  end
  
  def check_tax_rates
    self.tax_rates.count == 0
  end
end
