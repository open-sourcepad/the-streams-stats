class CreateHolidays < ActiveRecord::Migration[5.0]
  def change
    create_table :holidays do |t|
      t.string :name, default: ""
      t.date :date
      t.boolean :is_weekday, default: false

      t.timestamps
    end
  end
end
