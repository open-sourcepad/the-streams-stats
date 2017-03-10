class ReportsMailer < ApplicationMailer

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
    hash = {
      from: "admin@sourcepad.com",
      to: "ruthg@sourcepad.com",#user.email,
      subject: "Daily Report"
    }
    mail(hash)
  end
end
