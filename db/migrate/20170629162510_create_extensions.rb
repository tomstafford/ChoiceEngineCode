class CreateExtensions < ActiveRecord::Migration[5.1]
  def change
    create_table :extensions do |t|
      t.text  :abbreviation, index: true
      t.timestamps
    end
  end
end
