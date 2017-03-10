module WorkLog
  BASE_URL = "http://streamsapp.co/api"
  DEFAULT_GOAL = 28800
  HALF_DAY = 14400

  def get_users
    url = "#{BASE_URL}/users"
    @users = JSON.parse(Nokogiri::HTML(get_tempfile(url)))
    @users.each do |u|
      puts u
      user = User.where(uuid: u["id"], email: u["email"], name: u["name"]).first_or_initialize
      user.password = "123456"
      user.save
    end
  end

  def get_projects
    url = "#{BASE_URL}/projects"
    @projects = JSON.parse(Nokogiri::HTML(get_tempfile(url)))
    @projects.each do |p|
      puts p
      project = Project.where(pid: p["id"], name: p["name"], slug: p["slug"]).first_or_initialize
      project.save
    end
  end

  def get_project_hours(start_date, end_date)
    start_date_range = Time.now.beginning_of_week.in_time_zone("Eastern Time (US & Canada)").strftime("%FT%T%:z")
    end_date_range = Time.now.end_of_day.in_time_zone("Eastern Time (US & Canada)").strftime("%FT%T%:z")

    User.all.each do |user|
      url = "#{BASE_URL}/users/#{user.uuid}/worklogs?start_date=#{start_date_range}&end_date=#{end_date_range}"
      @logs = JSON.parse(Nokogiri::HTML(get_tempfile(url)))

      user.project_daily_summaries.update_all(rendered_hours: 0)

      @logs["worklogs"].each do |data|
        project = Project.where(pid: data["project_id"]).first_or_create
        proj_hour = ProjectDailySummary.where(user_id: user.id, project_id: project.id, work_date: data["started_at"].to_date).first_or_initialize
        proj_hour.rendered_hours += data["billable_duration"]
        proj_hour.save
      end

      (Date.today.beginning_of_week..Date.today).each do |d|
        daily_summary(user, d)
      end
    end
  end

  def generate_monthly_data
    User.all.each do |user|
      (Date.today.beginning_of_month..Date.today.end_of_month).each do |d|
        daily = user.daily_summaries.where(work_date: d).first
        unless daily.present?
          daily = user.daily_summaries.create(work_date: d, rendered_hours: 0, hours_goal: goal_hour(user, d))
        end
      end
    end
  end

  def daily_summary(user, work_date)
    daily = user.daily_summaries.where(work_date: work_date).first_or_initialize
    daily.rendered_hours = user.project_daily_summaries.where(work_date: work_date).sum(:rendered_hours)
    daily.hours_goal = goal_hour(user, work_date)
    daily.save
  end

  def goal_hour(user, work_date)
    if ["Sat","Sun"].include?(work_date.strftime("%a"))
      0
    else
      day_off = user.day_offs.where(start_date: work_date).first
      if day_off.present?
        day_off.half_day? ? HALF_DAY : 0
      else
        DEFAULT_GOAL
      end
    end
  end

  def get_tempfile(url)
    open(url, 'utoken' => 'EbCPzz77_2P535ty9EUB', 'uid' => "12", 'accept' =>  "application/json,application/vnd.streams+json;version=1")
  end
end
