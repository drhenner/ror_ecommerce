module MainPrinter
  include ActionView::Helpers::NumberHelper
  DEFAULT_SIZE = 13

  def check_box(pdf,x_location,y_location, check_size = 12)
    pdf.text "X", :at => [x_location,y_location], :size => check_size
  end

  # Converts the lines to actual text
  #
  # @param [pdf] pdf to be printed on
  # @param [lines] array of string to be printed normally within a bounding box
  def print_lines(pdf, lines)
    lines.each do |line|
      pdf.text line
    end if lines
  end

  def image_uri(url, name)
    if Rails.env == 'development'
      [Rails.root, "/app/assets/images/#{name}"].join
    else
      URI.join(url, ActionController::Base.helpers.asset_path(name))
    end
  end

  # at is an array with X & Y...  [200, 100]
  # amount in decimal  100.0  => 100 dollars
  def draw_currency_at(pdf, amount, at, size = MainPrinter::DEFAULT_SIZE)
    pdf.draw_text number_to_currency(amount), { at: at, size: size }
  end

  # Converts the string to actual text
  #
  # @param [pdf] pdf to be printed on
  # @param [display_string] string to be printed
  # @param [yml_info] customization
  def print_line(pdf, display_string, yml_info)

    arguements         = {}
    if yml_info['arguements']['at']
      x_loc = yml_info['arguements']['at'][0].to_f
      y_loc = yml_info['arguements']['at'][1].to_f
      arguements[:at]    = [x_loc, y_loc]
    end

    if yml_info['arguements']['size']
      arguements[:size]  = yml_info['arguements']['size']
    else
      arguements[:size]  = MainPrinter::DEFAULT_SIZE
    end
    pdf.draw_text display_string, arguements
  end

  ## method: checker_form(pdf)
  ## This is a method to see the x-y locations throughout your document
  # This is a good method for developing a new form
  # input:  pdf
  # returns: pdf with x-y grid

  def checker_form(pdf)
    add_num = 5
    0.upto(65) { |i| pdf.draw_text "#{(i*10+add_num).to_s},#{(i*15).to_s}",  :at => [(i*10+add_num),(i*15)], :size => 10 }
    0.upto(65) { |i| pdf.line [(i*10+add_num),0], [(i*10+add_num),800] }
    0.upto(75) { |i| pdf.draw_text "#{(i*10 + add_num).to_s}",             :at => [100,(i*10 + add_num)], :size => 10 }
    0.upto(75) { |i| pdf.line [0,(i*10 + add_num)], [800,(i*10 + add_num)] }
#
#    0.upto(60) { |i| pdf.text "#{(i*10).to_s},40",  :at => [(i*10),(i*15)], :size => 8 if i.modulo(5) == 0 }
#    0.upto(60) { |i| pdf.text "#{(i*10).to_s},755", :at => [(i*10),(i*15)], :size => 8 if i.modulo(5) == 0 }
#    0.upto(75) { |i| pdf.text "36,#{(i*10).to_s}",  :at => [0,(i*10)],    :size => 8 }
#    0.upto(75) { |i| pdf.text "590,#{(i*10).to_s}", :at => [100,(i*10)],    :size => 8 }
    pdf.stroke()
  end

  def checker_background(pdf, png_background = nil)
    pdf.bounding_box([10,730], :width => 530) do
      pdf.image png_background, :width => 519 if png_background
      checker_form(pdf)
    end
  end # end of print_form method
end
