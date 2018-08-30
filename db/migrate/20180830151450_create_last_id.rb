class CreateLastId < ActiveRecord::Migration[5.1]

  def change
    create_table :last_ids do |t|
      t.bigint     :last_twitter_id
      t.bigint     :last_reply_id
      t.timestamps
    end
  end
end