class AddLastTweetUrl < ActiveRecord::Migration[5.1]
  def change
    add_column :interactions, :our_tweet_url, :text
  end
end
