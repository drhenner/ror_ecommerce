FactoryBot.define do
  factory :image do
    imageable { |c| c.association(:product) }
    caption { 'Caption blah.' }
    position { 1 }

    after(:build) do |img|
      img.photo.attach(
        io: File.open(Rails.root.join('spec', 'support', 'rails.png')),
        filename: 'rails.png',
        content_type: 'image/png'
      )
    end
  end
end
