class CreateProjectDailySummaries < ActiveRecord::Migration[5.0]
  def change
    create_table :project_daily_summaries do |t|
      t.integer :project_id
      t.integer :user_id
      t.date :work_date
      t.decimal :hours_goal, default: 0
      t.decimal :rendered_hours, default: 0

      t.timestamps
    end
  end
end
