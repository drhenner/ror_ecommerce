FactoryGirl.define do
  factory :tax_rate do
    percentage      7.25
    state           { State.first }
    start_date      Time.now.to_date
    end_date        (Time.now + 1.day).to_date
    active          true
  end
end
