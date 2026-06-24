class MakeUserIdNotNullOnStudents < ActiveRecord::Migration[8.1]
  def change
    change_column_null :students, :user_id, false
  end
end
