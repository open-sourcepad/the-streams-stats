class ReportsMailer < ApplicationMailer
  add_template_helper(ApplicationHelper)
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.reports_mailer.daily_report.subject
  #
  def daily_report(user)
    @user = user
    @daily_reports = user.daily_summaries.where("work_date >= ? AND work_date <= ?", Date.yesterday.beginning_of_week, Date.yesterday)
    @weekly_reports = user.daily_summaries.where("work_date >= ? AND work_date <= ?", Date.yesterday.beginning_of_week, Date.yesterday.end_of_week)
    @monthly_reports = user.daily_summaries.where("work_date >= ? AND work_date <= ?", Date.yesterday.beginning_of_month, Date.yesterday.end_of_month)
    @daily = @daily_reports.where(work_date: Date.yesterday).first

    @week_acc = ((@weekly_reports.sum(:rendered_hours)/@weekly_reports.sum(:hours_goal)) * 100).round(0)
    @month_acc = ((@monthly_reports.sum(:rendered_hours)/@monthly_reports.sum(:hours_goal)) * 100).round(0)
    generate_graph
    hash = {
      from: "admin@sourcepad.com",
      to: user.email,
      subject: "Daily Report"
    }

    attachments.inline['header.png'] = {
      data: File.read(Rails.root.join('app/assets/images/header.png')),
      mime_type: 'image/png'
    }

    attachments.inline["daily_report_#{@user.name.downcase.gsub(' ','_')}.png"] = {
      data: File.read(Rails.root.join('app', 'assets', 'images', "daily_report_#{@user.name.downcase.gsub(' ','_')}.png")),
      mime_type: 'image/png'
    }

    attachments.inline["daily_report_pie_#{@user.name.downcase.gsub(' ','_')}.png"] = {
      data: File.read(Rails.root.join('app', 'assets', 'images', "daily_report_pie_#{@user.name.downcase.gsub(' ','_')}.png")),
      mime_type: 'image/png'
    }
    attachments.inline["daily_report_stack_#{@user.name.downcase.gsub(' ','_')}.png"] = {
      data: File.read(Rails.root.join('app', 'assets', 'images', "daily_report_stack_#{@user.name.downcase.gsub(' ','_')}.png")),
      mime_type: 'image/png'
    }


    mail(hash)
  end

  def generate_graph
    generate_line_graph
    generate_pie_chart
    generate_stack
  end

  def generate_pie_chart
    g = Gruff::Pie.new
    g.title = "Weekly Project Breakdown"
    @project_data = @user.project_daily_summaries.where("work_date >= ? AND work_date <= ?", Date.yesterday.beginning_of_week, Date.yesterday).select(:project_id, "SUM(rendered_hours) as total_hours").group(:project_id)


    @user.project_daily_summaries
    @project_data.each_with_index do |d, index|
      g.data(d.project.name, d.total_hours/3600)
    end

    g.write(Rails.root.join('app', 'assets', 'images', "daily_report_pie_#{@user.name.downcase.gsub(' ','_')}.png"))
  end

  def generate_stack
    @datasets = [
      [:Jimmy, [25, 36, 86, 39]],
      [:Charles, [80, 54, 67, 54]],
      [:Julie, [22, 29, 35, 38]],
      ]


    g = Gruff::StackedBar.new
    g.title = "Weekly Comparison"


    start_date = Date.yesterday.beginning_of_month
    end_date = Date.yesterday.end_of_month
    result = (start_date..end_date).to_a.select {|k| k.wday.eql?(1)}
    label_hash = {}
    result.each_with_index do |d, index|
      label_hash.merge!(index => d.strftime("%m/%d"))
    end

    data_hash = {}
    project_ids = @user.project_daily_summaries.where("work_date >= ? AND work_date <= ?",start_date, end_date).pluck(:project_id).uniq!
    project_ids.each do |project|
      week_hours = []
      project_name = ""
      result.each do |d|
        project_data = @user.project_daily_summaries.where("work_date >= ? AND work_date <= ? AND project_id = ?", d.beginning_of_week, d.end_of_week, project)
        if project_data.count > 0
          week_hours.push(project_data.sum(:rendered_hours)/3600)
          project_name = project_data.first.project.name
        else
          week_hours.push(0)
        end
      end
      data_hash.merge!("#{project_name}" => week_hours)
    end

    g.labels = label_hash
    data_hash.to_a.each do |data|
      g.data(data[0], data[1])
    end
    g.write(Rails.root.join('app', 'assets', 'images', "daily_report_stack_#{@user.name.downcase.gsub(' ','_')}.png"))

  end

  def generate_line_graph
    g = Gruff::Line.new
    g.title = 'Daily Total Hours'

    label_hash = {}
    hours_hash = []

    @weekly_reports.order(:work_date).each_with_index do |d, index|
      label_hash.merge!(index => d.work_date.strftime("%a %m/%d"))
      hours_hash.push(d.rendered_hours/3600)
    end

    g.labels = label_hash
    g.data @user.name, hours_hash
    g.write(Rails.root.join('app', 'assets', 'images', "daily_report_#{@user.name.downcase.gsub(' ','_')}.png"))
  end

end
