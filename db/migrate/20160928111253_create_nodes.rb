class CreateNodes < ActiveRecord::Migration
  def change
    create_table :nodes do |t|
      t.string :name
      t.string :kind
      t.string :template
      t.string :ancestry
      t.integer :book_id
      t.timestamps null: false
    end
    add_index :nodes, :ancestry
  end
end
