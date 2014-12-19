require 'spec_helper'

describe Sale, '#for(product_id, at)' do
  it "should return sale" do
    product = FactoryGirl.create(:product)
    new_sale = FactoryGirl.create(:sale,
                                  :product_id   => product.id,
                                  :starts_at    => (Time.zone.now - 1.days),
                                  :ends_at      => (Time.zone.now + 1.days),
                                  :percent_off  => 0.20
                                  )

    sale = Sale.for(product.id, Time.zone.now)
    expect(sale.id).to eq new_sale.id

    sale = Sale.for(product.id, (Time.zone.now - 2.days))
    expect(sale).to be_nil

    sale = Sale.for(product.id, (Time.zone.now + 2.days))
    expect(sale).to be_nil
  end
end
