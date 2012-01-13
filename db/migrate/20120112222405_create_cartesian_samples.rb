class CreateCartesianSamples < ActiveRecord::Migration
  def self.up
    create_table :cartesian_samples do |t|
      t.string :author, :default => 'anonymous', :null => false
      t.string :classname, :default => '', :null => false
      t.string :bandstring, :default => '', :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :cartesian_samples
  end
end
