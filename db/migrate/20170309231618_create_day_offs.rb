class CreateDayOffs < ActiveRecord::Migration[5.0]
  def change
    create_table :day_offs do |t|
      t.belongs_to :user
      t.date :start_date
      t.date :end_date
      t.boolean :half_day, default: false
      t.text :reason, default: ''
      t.text :note, default: ''
      t.string :status, default: 'pending'

      t.timestamps
    end
  end
end
