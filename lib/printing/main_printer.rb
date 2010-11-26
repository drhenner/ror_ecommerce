module MainPrinter

  def check_box(pdf,x_location,y_location, check_size = 12)
    pdf.text "X", :at => [x_location,y_location], :size => check_size
  end

  ## method: checker_form(pdf)
  ## This is a method to see the x-y locations throughout your document
  # This is a good method for developing a new form
  # input:  pdf
  # returns: pdf with x-y grid

  def checker_form(pdf)
    add_num = 5
    0.upto(65) { |i| pdf.text "#{(i*10+add_num).to_s},#{(i*15).to_s}",  :at => [(i*10+add_num),(i*15)], :size => 10 }
    0.upto(65) { |i| pdf.line [(i*10+add_num),0], [(i*10+add_num),800] }
    0.upto(75) { |i| pdf.text "#{(i*10 + add_num).to_s}",             :at => [100,(i*10 + add_num)], :size => 10 }
    0.upto(75) { |i| pdf.line [0,(i*10 + add_num)], [800,(i*10 + add_num)] }
#
#    0.upto(60) { |i| pdf.text "#{(i*10).to_s},40",  :at => [(i*10),(i*15)], :size => 8 if i.modulo(5) == 0 }
#    0.upto(60) { |i| pdf.text "#{(i*10).to_s},755", :at => [(i*10),(i*15)], :size => 8 if i.modulo(5) == 0 }
#    0.upto(75) { |i| pdf.text "36,#{(i*10).to_s}",  :at => [0,(i*10)],    :size => 8 }
#    0.upto(75) { |i| pdf.text "590,#{(i*10).to_s}", :at => [100,(i*10)],    :size => 8 }
    pdf.stroke()
  end

  def checker_background(report_name, png_background = nil)
    document = Prawn::Document.generate report_name do |pdf|
      #pdf.font "Times-Roman"

      pdf.bounding_box([-30,820], :width => 640, :height => 820) do
          pdf.image png_background,:at => [-10,780] ,:height => 835, :width => 625  if png_background
          checker_form(pdf)
      end
      # Save the report if a file name was passed to the file
      pdf.render_file report_name #unless report_name.match('preview')
    end # end of Prawn::Document.generate
    return document
  end # end of print_form method
end