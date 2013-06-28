FactoryGirl.define do
  factory :payment_profile do
    user            { |c| c.association(:user) }
    address         { |c| c.association(:address) }
    payment_cim_id  123456789
    default         true
    active          true
    cc_type         'visa'
    month           '05'
    year            { Time.now.year + 1 }
    last_digits     '3955'
    credit_card_info  do
      {
        :number       => '4916477365453955',
        :verification_value => '343',
        :month        => '05',
        :year         => (Time.now.year + 1),
        :first_name   => 'David',
        :last_name    => 'Bowe',
        :brand        => 'visa'
      }
    end
  end
end
