self.extend InvoicePrinter

pdf.start_new_page()

#logopath = "#{Rails.root}/public/images/invoice_template.png"

#checker_background pdf, logopath

print_invoice_background(pdf)
print_order_invoice_form( pdf, @invoice )








#pdf.bounding_box([10,730], :width => 530) do
#  pdf.image logopath, :width => 519
#end