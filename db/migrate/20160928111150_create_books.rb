class CreateBooks < ActiveRecord::Migration
  def change
    create_table :books do |t|
      t.string :title
      t.string :kind
      t.text :book_plan
      t.timestamps null: false
    end
  end
end
