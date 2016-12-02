class AddOpenAttribute < ActiveRecord::Migration
  def change
    add_column :courses, :courses_open, :boolean, :default => false
  end
end
