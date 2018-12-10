module ChoiceEngine
  class Utils

    UN1 = "@choiceengine".freeze
    UN2 = "@ChoiceEngine".freeze
    UN3 = "@Choiceengine".freeze
    USER_NAMES = [ UN1, UN2, UN3 ]

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

    def self.follow_if_we_do_not(tweeting_user_id)
      return if tweeting_user_id == ENV['TWITTER_USER_ID']
      if client.follower_ids.include?(tweeting_user_id)
        pp "This user follows already"
      else
        pp "This user does not follow us"
      end

      pp "These are the followers of the tweeting user id"
      pp  client.follower_ids(tweeting_user_id)


      if client.follower_ids(ENV['TWITTER_USER_ID']).include?(tweeting_user_id)
        pp "We are following them"
      else
        pp "We are not following them"
        client.follow(tweeting_user_id)
      end

      # if client.follower_ids(tweeting_user_id)

      # if iclient.follower_ids
    end
  end
end
