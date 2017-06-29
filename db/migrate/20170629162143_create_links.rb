class CreateLinks < ActiveRecord::Migration[5.1]

  def change
    create_table :links do |t|
      t.references  :post, index: true
      t.integer     :outgoing_post_id, index: true
      t.text        :abbreviation, index: true
      t.timestamps
    end
  end

end
