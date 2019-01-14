require 'pry'

module ChoiceEngine
  class Utils
    UN1 = "@choiceengine".freeze
    UN2 = "@ChoiceEngine".freeze
    UN3 = "@Choiceengine".freeze
    USER_NAMES = [UN1, UN2, UN3].freeze

    def self.remove_username_from_text(text)
      text = text.dup if text.frozen?
      text.slice! UN1
      text.slice! UN2
      text.slice! UN3
      text
    end

    def self.update_last_id(last_id)
      if ChoiceEngine::LastId.any?
        ChoiceEngine::LastId.first.update(last_twitter_id: last_id)
      else
        ChoiceEngine::LastId.create(last_twitter_id: last_id)
      end
    end

    def self.is_this_id_our_id?(tweeting_user_id)
      tweeting_user_name = client.user(tweeting_user_id).name
      pp "Tweeting user id #{tweeting_user_id} #{tweeting_user_name}"
      pp "Env: #{ENV['TWITTER_USER_ID']}"
      pp tweeting_user_id.to_s == ENV['TWITTER_USER_ID'].to_s
      tweeting_user_id.to_s == ENV['TWITTER_USER_ID'].to_s
    end

    def self.are_we_following_them?(tweeting_user_id)
      follower_ids_from_tweeting_user_id = client.follower_ids(tweeting_user_id).attrs[:ids]
      pp follower_ids_from_tweeting_user_id
      pp "This is the tweeting user id: #{tweeting_user_id} name: #{client.user(tweeting_user_id).name}"
      pp "this is the current followers from this user: #{follower_ids_from_tweeting_user_id}"
      pp "these users: "
      follower_ids_from_tweeting_user_id.each { |a| pp client.user(a).name }
      follower_ids_from_tweeting_user_id.include?(tweeting_user_id)
    end

    def self.follow_if_we_do_not(tweeting_user_id)
      return if is_this_id_our_id?(tweeting_user_id)

      if client.follower_ids.include?(tweeting_user_id)
        pp "This user follows already"
      else
        pp "This user does not follow us"
      end

      pp "These are the followers of the tweeting user id"

      if are_we_following_them?(tweeting_user_id)
        pp "We are following them"
      elsif is_this_id_our_id?(tweeting_user_id)
        pp "this is us!"
        pp "We are not following them, so follow them now"
        client.follow(tweeting_user_id)
      end
    end
  end
end
