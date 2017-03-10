class DayOff < ApplicationRecord
  belongs_to :user

  scope :approved, -> { where(status: Constants::APPROVED) }
end
