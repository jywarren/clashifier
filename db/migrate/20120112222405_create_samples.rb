class CreateSamples < ActiveRecord::Migration
  def self.up
    create_table :samples do |t|
      t.string :author, :default => 'anonymous', :null => false
      t.string :classname, :default => '', :null => false
      t.string :bandstring, :default => '', :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :samples
  end
end
