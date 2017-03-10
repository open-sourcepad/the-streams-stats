class User < ApplicationRecord
  include WorkLog
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :day_offs
  has_many :project_daily_summaries
  has_many :daily_summaries

  def seed_users_and_projects
    get_users
    get_projects
  end
end
