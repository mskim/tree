class AddPageNumberAndCountToNode < ActiveRecord::Migration
  def change
    add_column :nodes, :page_count, :integer
    add_column :nodes, :starting_page, :integer
  end
end
