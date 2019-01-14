#!/usr/bin/env ruby
require 'rubygems'
require 'dotenv'

require_relative 'choice_engine/responder.rb'
require_relative 'choice_engine/last_id.rb'
require_relative 'choice_engine/utils.rb'
require_relative 'database_config.rb'


Dotenv.load('../.env')

require_relative 'chatterbox_config'
require_relative 'chatterbox/reply.rb'

uptime_messages = [
"The Choice Engine is an interactive essay about the psychology, neuroscience and philosophy of free will. Follow and reply START to begin.",
"The Choice Engine is brought to you by: @tomstafford - Words; @J_o_n_C_a_n - Design; @jamesjefferies - Code; A @FestivalMind project.",
"I don't respond to replies immediately. Sometimes it can take a few hours, but I will get to yours soon. Make sure you are following to ensure you see replies.",
"Reply with RESET to clear your history.",
"Twitter sometimes hides my replies. Please follow me to ensure you see replies to your messages (if you have 'quality filter' ticked in Settings > Notifications you may not be notified of my replies). More on this here https://tomstafford.github.io/choice-engine-text/teething.",
"Make sure you are following to ensure you see replies."
]

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
      test_value = [:reply, :tweet, :wait, :wait_again].sample
      test_value = :reply
      if test_value == :reply
        DatabaseConfig.make_normal_connection

        # Update last since check
        last_id = client.search("a", since:Time.now - 100).attrs[:search_metadata][:max_id]
        ChoiceEngine::Utils::update_last_id(last_id)

        replies do |tweet|
          if tweet.user.screen_name == ENV['TWITTER_USER_NAME']
            p "Don't reply to yourself: #{tweet.text}"
          else
            # We need to check this tweet still exists
            # We should follow if we don't already
            pp "We have received Tweet id #{tweet.id} from this user id: #{tweet.user.id}"
            pp tweet.user

            ChoiceEngine::Utils.follow_if_we_do_not(tweet.user.id)

            text = ChoiceEngine::Utils.remove_username_from_text(tweet.text)
            response = ChoiceEngine::Responder.new(text, tweet.user.screen_name).respond
            client.update("@#{tweet.user.screen_name} #{response}", in_reply_to_status_id: tweet.id)
           # reply "#USER# #{response}", tweet
          end
        end
      elsif test_value == :tweet
        message = uptime_messages.sample + " (#{Time.now.utc.to_s})"
        tweet message
      end
    end
  end
end
