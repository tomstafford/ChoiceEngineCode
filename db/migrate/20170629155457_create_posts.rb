class CreatePosts < ActiveRecord::Migration[5.1]

  def change
    create_table :posts do |t|
      t.text        :title
      t.text        :description
      t.text        :url
      t.boolean     :start
      t.boolean     :end
      t.integer     :importance
      t.timestamps
    end
  end
end
