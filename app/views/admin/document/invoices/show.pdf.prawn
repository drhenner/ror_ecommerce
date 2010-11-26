logopath = "#{Rails.root}/public/images/invoice_template.png"

pdf.bounding_box([10,730], :width => 530) do
  pdf.image logopath, :width => 519
end