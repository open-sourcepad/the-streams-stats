module WorkLog
  extend ActiveSupport::Concern

  BASE_URL = "http://streamsapp.co/api"
  DEFAULT_GOAL = 28800

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
    start_date = Date.today.beginning_of_week.to_datetime.in_time_zone("Eastern Time (US & Canada)").strftime("%FT%T%:z")
    end_date = Date.today.end_of_day.to_datetime.in_time_zone("Eastern Time (US & Canada)").strftime("%FT%T%:z")

    User.all.each do |user|
      url = "#{BASE_URL}/users/#{user.uuid}/worklogs?start_date=#{start_date}&end_date=#{end_date}"
      @logs = JSON.parse(Nokogiri::HTML(get_tempfile(url)))

      user.project_daily_summaries.update_all(rendered_hours: 0)

      @logs["worklogs"].each do |data|
        project = Project.where(pid: data["project_id"]).first_or_create
        proj_hour = ProjectDailySummary.where(user_id: user.id, project_id: project.id, work_date: data["started_at"].to_date).first_or_initialize
        proj_hour.rendered_hours += data["duration"]
        proj_hour.save
      end
    end
  end

  def daily_summary(user, work_date)
    daily = user.daily_summaries.where(work_date: work_date).first_or_initialize
    daily.rendered_hours = user.project_daily_summaries.where(work_date: work_date).sum(:rendered_hours)

  end

  def day_off
  end

  def weekly_summary
  end

  def get_tempfile(url)
    open(url, 'utoken' => 'EbCPzz77_2P535ty9EUB', 'uid' => "12", 'accept' =>  "application/json,application/vnd.streams+json;version=1")
  end
end
