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

  def print_invoice_background(pdf, png_background = background_png )
    print_png_background(pdf, png_background)
    print_logo(pdf)
  rescue OpenURI::HTTPError => e
    pdf.bounding_box([20,720], width: 120) do
      pdf.draw_text "LOGO", { size: 32, at: [50,50] }
    end
  end

  def background_png
    image_uri(root_url, "invoice_template.png")
  end

  def logo_png
    image_uri(root_url, "logos/logo.png")
  end

  def print_png_background(pdf, png_background)
    pdf.bounding_box([10,730], width: 530) do
      pdf.image open(png_background), width: 519 if png_background && ENV['FOG_DIRECTORY'].present?
    end
  end

  def print_logo(pdf)
    pdf.bounding_box([20,720], width: 120) do
      pdf.image open(logo_png) if ENV['FOG_DIRECTORY'].present?
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
    line_items_details(pdf, invoice)
    shipping_charges_details(pdf, invoice)
    coupon_details(pdf, invoice)
    deal_details(pdf, invoice)
    final_price_details(pdf, invoice)
  end

  def shipping_charges_details(pdf, invoice)
    pdf.draw_text 'Shipping',      { at: [130, 270] }
    draw_currency_at(pdf, invoice.order.shipping_charges, [470, 270])
  end

  def coupon_details(pdf, invoice)
    if invoice.order.coupon_id
      pdf.draw_text 'Coupon',      { at: [130, 257] }
      draw_currency_at(pdf, invoice.order.coupon_amount, [470, 257])
    end
  end

  def deal_details(pdf, invoice)
    if invoice.order.deal_amount && invoice.order.deal_amount > 0.0
      pdf.draw_text 'Deal',      { at: [130, 244] }
      draw_currency_at(pdf, invoice.order.deal_amount, [470, 244])
    end
  end

  def final_price_details(pdf, invoice)
    draw_currency_at(pdf, invoice.order.total_tax_charges.round_at(2), [480, 175], 10)
  end

  def line_items_details(pdf, invoice)
    invoice.order.order_items.each_with_index do |item, i|
      new_page(pdf, invoice) if ((i) % 3) == 0 && i > 1
      line_item_details(pdf, item, i)
    end
  end

  def line_item_details(pdf, item, line_num)
    pdf.draw_text item.variant.product_name,      { at: [130, 420 - (line_num * 50) ] }
    draw_currency_at(pdf, item.price, [470, 420 - (line_num * 50)])
  end

  def next_num
    @num ||= 0
    @num = @num + 1
  end

  def reset_num
    @num = 0
  end

  def new_page(pdf, invoice, start_new_page = true)
    pdf.start_new_page() if start_new_page
    pdf.font "#{Rails.root}/lib/printing/fonts/DejaVuSans.ttf"
    print_invoice_background(pdf)
    print_header_details(pdf, invoice)
  end

  def print_header_details(pdf, invoice)
    pdf.bounding_box([0,400], width: 612) do
      @invoice_yml.each do |info|
        if info.last['multiple_lines']
          print_multiple_lines(pdf, invoice, info)
        else
          print_line(pdf, invoice.send(info.last['method'].to_sym), info.last )
        end
      end
    end
  end

  def print_multiple_lines(pdf, invoice, info)
    pdf.bounding_box(   [  info.last['arguements']['bounded_at'][0].to_i,
                          info.last['arguements']['bounded_at'][1].to_i
                        ],
                          width: info.last['arguements']['bounded_by'][0].to_i,
                          height: info.last['arguements']['bounded_by'][1].to_i
                        ) do
      print_lines(pdf, invoice.send(info.last['method'].to_sym) )
    end
  end
end
