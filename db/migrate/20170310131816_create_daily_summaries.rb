class CreateDailySummaries < ActiveRecord::Migration[5.0]
  def change
    create_table :daily_summaries do |t|
      t.integer :user_id
      t.decimal :hours_goal
      t.decimal :rendered_hours
      t.date :work_date

      t.timestamps
    end
  end
end
