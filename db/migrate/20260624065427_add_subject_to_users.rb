class AddSubjectToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :subject, :string
  end
end
