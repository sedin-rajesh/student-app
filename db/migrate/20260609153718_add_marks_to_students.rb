class AddMarksToStudents < ActiveRecord::Migration[8.1]
  def change
    add_column :students, :marks, :integer
  end
end
