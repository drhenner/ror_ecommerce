class Sale < ApplicationRecord
  #attr_accessible :ends_at, :percent_off, :product_id, :starts_at

  belongs_to :product

  validates :product_id,    presence: true
  validates :ends_at,       presence: true
  validates :starts_at,     presence: true
  validates :percent_off,   presence: true


  def self.for(product_id, at)
    where(['sales.product_id = ? AND sales.starts_at <= ? AND sales.ends_at > ?', product_id, at, at]).order('sales.percent_off DESC').first
  end
end
