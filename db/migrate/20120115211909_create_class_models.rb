class CreateClassModels < ActiveRecord::Migration
  def self.up
    create_table :class_models do |t|
      t.string :classnames, :default => "", :null => false # comma-delimited list of classnames in this model
      t.string :modelstring, :default => "", :null => false # json string describing average values for each band, within each classname, with sample counts
      t.string :author, :default => "anonymous", :null => false
      t.text :notes, :default => "", :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :class_models
  end
end
