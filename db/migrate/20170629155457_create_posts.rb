class Createposts < ActiveRecord::Migration[5.1]

  def change
    create_table :posts do |t|
      t.text        :title
      t.text        :url
      t.boolean     :start
      t.boolean     :end
      t.integer     :type
      t.timestamps
    end
  end

end
