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


    mail(hash)
  end

  def generate_graph
    generate_line_graph
    generate_pie_chart
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
