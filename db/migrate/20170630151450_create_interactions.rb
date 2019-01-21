class CreateInteractions < ActiveRecord::Migration[5.1]
  def change
    create_table :interactions do |t|
      t.text        :username
      t.references  :post, index: true
      t.timestamps
    end
  end
end
