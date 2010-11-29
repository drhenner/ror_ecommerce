module MainPrinter

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