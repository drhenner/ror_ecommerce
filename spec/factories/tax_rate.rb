
Factory.define :tax_rate do |f|
  f.percentage      7.25
  f.tax_status      { TaxStatus.first }
  f.state           { |c| c.association(:state) }
  f.start_date      Time.now.to_date
  f.end_date        (Time.now + 1.day).to_date
  f.active          true
end