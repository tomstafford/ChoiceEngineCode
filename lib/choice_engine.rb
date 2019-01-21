require 'rubygems'
require 'dotenv'

require_relative 'choice_engine/responder.rb'
require_relative 'choice_engine/utils.rb'

Dotenv.load('../.env')

require_relative 'chatterbox_config'
# Overriding chatterboxes reply
require_relative 'chatterbox/reply.rb'

UPTIME_MESSAGES = [
"The Choice Engine is an interactive essay about the psychology, neuroscience and philosophy of free will. Follow and reply START to begin.",
"The Choice Engine is brought to you by: @tomstafford - Words; @J_o_n_C_a_n - Design; @jamesjefferies - Code; A @FestivalMind project.",
"I don't respond to replies immediately. Sometimes it can take a few hours, but I will get to yours soon. Make sure you are following to ensure you see replies.",
"Reply with RESET to clear your history.",
"Twitter sometimes hides my replies. Please follow me to ensure you see replies to your messages (if you have 'quality filter' ticked in Settings > Notifications you may not be notified of my replies). More on this here https://tomstafford.github.io/choice-engine-text/teething.",
"Make sure you are following to ensure you see replies."
].freeze

#<Twitter::SearchResults:0x00007fb09eacd338
 # @attrs=
 #  {:statuses=>[],
 #   :search_metadata=>
 #    {:completed_in=>0.022,
 #     :max_id=>1035261852706643968,
#

module ChoiceEngine
  class Runner
    def self.run
      action = what_to_do_this_time?

      if action == :reply
        reply_action
      elsif action == :tweet
        tweet_action
      end
    end

    def self.reply_action
      # Update last since check in case we have no replies, we search for a
      last_id = client.search("a", since: Date.today.strftime('%Y-%m-%d')).attrs[:search_metadata][:max_id]
      ChoiceEngine::Utils::update_last_id(last_id)

      # These replies come from chatterbot, everything in this block gets run per tweet
      replies do |tweet|
        if tweet.user.screen_name == ENV['TWITTER_USER_NAME']
          p "Don't reply to yourself: #{tweet.text}"
        else
          reply_to_tweet(tweet)
        end
      end
    end

    def self.reply_to_tweet(tweet)
      # We need to check this tweet still exists
      # We should follow if we don't already
      p ' ' * 80
      p '#' * 80
      p 'Reply to tweet'
      user_screen_name = tweet.user.screen_name
      pp "We have received Tweet id #{tweet.id} from this user name: #{user_screen_name}"
      ChoiceEngine::Utils.follow_if_we_do_not(tweet.user.id)

      text = ChoiceEngine::Utils.remove_username_from_text(tweet.text)
      response, new_post_id = ChoiceEngine::Responder.new(text, user_screen_name).response

      # Reply using Twitter API wrapped in chatterbot
      client_response = client.update("@#{user_screen_name} #{response}", in_reply_to_status_id: tweet.id)

      ChoiceEngine::Utils.create_interaction(user_screen_name, new_post_id, client_response.url)

      pp client_response.url
      p 'Reply to tweet'
      p '#' * 80
      p ' ' * 80
    end

    def self.tweet_action
      # Uses chatterbot tweet method
      tweet get_random_tweet_message
    end

    def self.get_random_tweet_message
      UPTIME_MESSAGES.sample + " (#{Time.now.utc})"
    end

    def self.what_to_do_this_time?
      if ENV['ENVIRONMENT'] == 'development' || ENV['ENVIRONMENT'] == 'test'
        p "Reply immediately as we are in development or test mode"
        return :reply
      end
      %i(reply tweet wait wait_again).sample
    end
  end
end
