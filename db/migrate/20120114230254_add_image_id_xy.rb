class AddImageIdXy < ActiveRecord::Migration
  def self.up
    add_column :samples, :image_id, :integer, :default => 0, :null => false
    add_column :samples, :xy, :string, :default => "", :null => false
  end

  def self.down
    remove_column :samples, :image_id
    remove_column :samples, :xy
  end
end
