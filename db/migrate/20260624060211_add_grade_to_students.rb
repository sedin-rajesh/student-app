class AddGradeToStudents < ActiveRecord::Migration[8.1]
  def change
    add_column :students, :grade, :string
  end
end
