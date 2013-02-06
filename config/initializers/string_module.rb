module StringModule

  def remove_words_less_than_x_characters( characters = 2 ) #d=0
    split(' ').                     # split into an array
    map{|w| w.length > characters ? w : ''}. # remove words less than 2 characters
    join(' ')
  end

  def remove_hyper_text
    squeeze(" ").                   # remove extra whitespace
    gsub(/<\/?[^>]*>/, "")          # remove hyper text
  end

  def remove_non_alpha_numeric
    gsub(/[^[:alnum:]]/, '')
  end

end
String.send :include, StringModule
