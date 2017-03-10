class WorkingDaysInMonth
  def initialize(date=Date.today.to_s)
    @date = Date.parse(date)
  end

  def number_of_working_days
    working_days.count
  end

  def working_days
    (@date.beginning_of_month..@date.end_of_month).select{ |e| weekdays.include?(e.wday) && !weekday_holidays.include?(e) }
  end

  def weekday_holidays
    @weekday_holidays ||= Holiday.weekdays.pluck(:date) # scope to just this month
  end

  private
    def weekdays
      (1..5).map(&:to_i)
    end
end