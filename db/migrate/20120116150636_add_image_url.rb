class AddImageUrl < ActiveRecord::Migration
  def self.up
    add_column :samples, :image_url, :string, :default => "", :null => false
    remove_column :samples, :image_id
  end

  def self.down
    remove_column :samples, :image_url
    add_column :samples, :image_id, :integer, :default => 0, :null => false
  end
end
