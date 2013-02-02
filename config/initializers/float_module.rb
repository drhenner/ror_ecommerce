module FloatModule

  def round_at( d ) #d=0
    (self * (10.0 ** d)).round.to_f / (10.0 ** d)
  end

end
Float.send :include, FloatModule
BigDecimal.send :include, FloatModule
