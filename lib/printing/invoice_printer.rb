require 'printing/main_printer'
module InvoicePrinter
  include MainPrinter
  include ActionView::Helpers::NumberHelper

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
    print_logo(pdf)
  end

  def print_logo(pdf)
    pdf.bounding_box([20,720], :width => 120) do
      pdf.image "#{Rails.root}/public/images/logos/#{Image::MAIN_LOGO}"
    end
  rescue
    pdf.bounding_box([20,720], :width => 120) do
      pdf.draw_text "LOGO", {:size => 32, :at => [100, 100]}
    end
  end

  def print_order_invoice_form( pdf,
                              invoice,
                              file_to_load = "#{Rails.root}/lib/printing/x_y_locations/invoice.yml" )

    @invoice_yml    = YAML::load( File.open( file_to_load ) )
    new_page(pdf, invoice, false)
    order_specific_details(pdf, invoice)
  end

  def order_specific_details(pdf, invoice)
    invoice.order.order_items.each_with_index do |item, i|
      new_page(pdf, invoice) if ((i) % 3) == 0 && i > 1
      pdf.draw_text item.variant.product_name,      {:at => [130, 420 - (i * 50) ]}
      pdf.draw_text number_to_currency(item.price), {:at => [470, 420 - (i * 50) ]}
    end
    invoice.order.shipping_rates.each_with_index do |shipping_rate, i|
      pdf.draw_text 'Shipping',      {:at => [130, 270 - (i * 15) ]}
      pdf.draw_text shipping_rate.rate,      {:at => [470, 270 - (i * 15) ]}
    end
    pdf.draw_text invoice.order.total_tax_charges,      {:at => [480, 175], :size => 10 }
  end

  def new_page(pdf, invoice, start_new_page = true)
    pdf.start_new_page() if start_new_page
    pdf.font "#{Rails.root}/lib/printing/fonts/DejaVuSans.ttf"
    print_invoice_background(pdf)
    new_page_bounding_box(pdf, invoice)
  end

  def new_page_bounding_box(pdf, invoice)
    pdf.bounding_box([0,400], :width => 612) do
      @invoice_yml.each do |info|
        display_string = invoice.send(info.last['method'].to_sym)
        if info.last['multiple_lines']
          pdf.bounding_box( bounded_at(info.last), bounded_by(info.last) ) do
            print_lines(pdf, display_string )
          end
        else
          print_line(pdf, display_string, info.last )
        end
      end
    end
  end


  # [Array]  [X-location, Y-location]
  def bounded_at(pdf_info)
    [pdf_info['arguements']['bounded_at'][0].to_i, pdf_info['arguements']['bounded_at'][1].to_i]
  end
  # [Hash]  {:width => 1, :height => 2 }
  def bounded_by(pdf_info)
    {:width => pdf_info['arguements']['bounded_by'][0].to_i, :height => pdf_info['arguements']['bounded_by'][1].to_i}
  end

  def print_bounding_box(pdf, invoice, pdf_info)
    pdf.bounding_box( bounded_at(pdf_info),bounded_by(pdf_info) ) do
        pdf.text invoice.send( pdf_info['arguements']['method'].to_sym )
    end
  end

end
