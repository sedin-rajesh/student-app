class AddStudentsCountToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :students_count, :integer, default: 0, null: false
  end
end
