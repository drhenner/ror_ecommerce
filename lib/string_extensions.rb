module StringExtensions
  def possessive
    self + case self[-1,1]#1.8.7 style
    when 's' then "'"
    else "'s"
    end
  end

  def is_numeric?
      Float self rescue false
  end
end

String.send :include, StringExtensions
