logopath = "#{Rails.root}/public/images/invoice_template.png"

pdf.bounding_box([-35,750], :width => 612) do
  pdf.image logopath, :width => 612
end