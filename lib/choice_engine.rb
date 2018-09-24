#!/usr/bin/env ruby
require 'rubygems'
require 'dotenv'
require 'awesome_print'
require_relative 'choice_engine/responder.rb'
require_relative 'choice_engine/last_id.rb'
require_relative 'choice_engine/utils.rb'
require_relative 'database_config.rb'

Dotenv.load('../.env')

require_relative 'chatterbox_config'

uptime_messages = [
"The Choice Engine is an interactive essay about the psychology, neuroscience and philosophy of free will. Follow and reply START to begin.",
"The Choice Engine is brought to you by: @tomstafford - Words; @J_o_n_C_a_n - Design; @jamesjefferies - Code; A @FestivalMind project.",
"I don't respond to replies immediately. Sometimes it can take a few hours, but I will get to yours soon. Make sure you are following to ensure you see replies.",
"There's a chance to ask questions and share your experiences of the project at a panel discussion in the Spiegaltent, Barkers Pool #Sheffield at 4pm on the 25th of September http://festivalofthemind.group.shef.ac.uk/the-choice-engine-talk/",
"The panel discussion for this project will feature @HelenaIfill, who will give us a Victorian perspective on choice and the mind, and @J_o_n_C_a_n who will take about how a designer thinks about people's choices.",
"Reply with RESET to clear your history then reply with START to start again.",
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

# MONKEY PATCH
# this block responds to mentions of your bot
module Chatterbot

  #
  # handle checking for mentions of the bot
  module Reply

    # handle replies for the bot
    def replies(&block)
      return unless require_login

      DatabaseConfig.make_normal_connection

      last_reply_id = ChoiceEngine::LastId.first.last_reply_id

      debug "check for replies since this twitter id - last reply id #{last_reply_id}"

      opts = {}
      opts[:since_id] = last_reply_id
      opts[:count] = 200

      results = client.mentions_timeline(opts)
      @current_tweet = nil

      max_reply_id = last_reply_id

      results.each { |s|
        if s.id > max_reply_id
          max_reply_id = s.id
        end
        @current_tweet = s
        yield s
      }
      ChoiceEngine::LastId.first.update(last_reply_id: max_reply_id)
      @current_tweet = nil
    end
  end
end

test_value = [1,2,3,4].sample

if test_value == 1
  DatabaseConfig.make_normal_connection

  # Update last since check
  last_id = client.search("a", since:Time.now - 100).attrs[:search_metadata][:max_id]
  ChoiceEngine::LastId.first.update(last_twitter_id: last_id)

  replies do |tweet|
    if tweet.user.screen_name == 'ChoiceEngine'
      p "Don't reply to yourself: #{tweet.text}"
    else
      text = ChoiceEngine::Utils.remove_username_from_text(tweet.text)
      response = ChoiceEngine::Responder.new(text, tweet.user.screen_name).respond
      reply "#USER# @#{tweet.user.screen_name} #{response}", tweet
    end
  end
elsif test_value == 6
  message = uptime_messages.sample + " (#{Time.now.utc.to_s})"
  tweet message
end


