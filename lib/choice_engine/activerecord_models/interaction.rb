require 'active_record'

module ChoiceEngine
  class Interaction < ActiveRecord::Base
    belongs_to :post

    def self.latest_post_for(username)
      p "Looking for latest post for #{username}"
      latest_posts = where(username: username).where.not(post_id: nil).order(created_at: :desc).limit(1)
      p "latest posts #{latest_posts}"
      latest_posts.first.post if latest_posts.any?
    end

    def to_s
      "#{id} - username: #{username} - post_id: #{post_id} - our_tweet_url: #{our_tweet_url}"
    end
  end
end
