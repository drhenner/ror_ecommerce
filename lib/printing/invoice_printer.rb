require 'printing/main_printer'
module InvoicePrinter
  include MainPrinter
  def print_form(order_invoice)
    document = Prawn::Document.new do |pdf|
      print_order_invoice_form(pdf, order_invoice)
      pdf#.render#_file card_name 
    end # end of Prawn::Document.generate
    return document
  end # end of print_form method
  
  def print_invoice_background(pdf, png_background = "#{Rails.root}/public/images/invoice_template.png")
    pdf.bounding_box([10,730], :width => 530) do
      pdf.image png_background, :width => 519 if png_background
    end
    pdf.bounding_box([20,720], :width => 120) do
      pdf.image "#{Rails.root}/public/images/logos/#{Image::MAIN_LOGO}.png"
    end
  end
  
  def print_order_invoice_form( pdf, 
                              invoice,
                              file_to_load = "#{Rails.root}/lib/printing/x_y_locations/invoice.yml" )
    pdf.font "#{Rails.root}/lib/printing/fonts/DejaVuSans.ttf"
    invoice_yml    = YAML::load( File.open( file_to_load ) )
    pdf.bounding_box([0,400], :width => 612) do
      invoice_yml.each do |info|
        pdf.bounding_box(    [  info.last['arguements']['bounded_at'][0].to_i,
                                info.last['arguements']['bounded_at'][1].to_i
                              ], 

                                :width => info.last['arguements']['bounded_by'][0].to_i, 
                                :height => info.last['arguements']['bounded_by'][1].to_i
                              ) do 

          print_lines(pdf, invoice.send(info.last['method'].to_sym) )
        end
      end
    end
  end
  
  def print_line(pdf, invoice, yml_info)
    
    arguements         = {}
    if yml_info['arguements']['at']
      x_loc = yml_info['arguements']['at'][0].to_f
      y_loc = yml_info['arguements']['at'][1].to_f
      arguements[:at]    = [x_loc, y_loc]
    end
    
    if yml_info['arguements']['size']
      arguements[:size]  = yml_info['arguements']['size']
    else
      arguements[:size]  = 13
    end
    pdf.draw_text invoice.send( pdf_info['arguements']['method'].to_sym ), arguements
  end
  
  def print_bounding_box(pdf, invoice, pdf_info)
    pdf.bounding_box( [ pdf_info['arguements']['bounded_at'][0].to_i,
                        pdf_info['arguements']['bounded_at'][1].to_i
                      ], 
                      :width  => pdf_info['arguements']['bounded_by'][0].to_i, 
                      :height => pdf_info['arguements']['bounded_by'][1].to_i
                    ) do 
        pdf.text invoice.send( pdf_info['arguements']['method'].to_sym )
    end
  end
  
end