class Holiday < ApplicationRecord
  validates :name, :date, presence: true
  after_save :update_is_weekday

  scope :weekdays, -> { where(is_weekday: true) }

  private
    def update_is_weekday
      update_column(:is_weekday, (1..5).include?(date.wday))
    end
end