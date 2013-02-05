module DateModule

  def age(at = Time.now.utc.to_date)
    at.year - self.year - ((at.month > self.month || (at.month == self.month && at.day >= self.day)) ? 0 : 1)
  end

end
Date.send :include, DateModule
