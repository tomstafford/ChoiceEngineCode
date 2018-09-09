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

uptime_messages = [ 'We are what we pretend to be, so we must be careful about what we pretend to be - Kurt Vonnegut',
  'Two roads diverged in a wood, and I - I took the one less traveled by, And that has made all the difference - Robert Frost',
  'Never open the door to a lesser evil, for other and greater ones invariably slink in after it - Baltasar Gracian',
  'Face your life, its pain, its pleasure, leave no path untaken - Neil Gaiman'
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

      last_id = ChoiceEngine::LastId.first.last_twitter_id
      last_reply_id = ChoiceEngine::LastId.first.last_reply_id

      debug "check for replies since this twitter id - last reply id #{last_reply_id} and last id #{last_id}"


      opts = {}
      if last_reply_id > 0
        opts[:since_id] = last_reply_id
      elsif last_id > 0
        opts[:since_id] = last_id
      end
      opts[:count] = 200

      results = client.mentions_timeline(opts)
      @current_tweet = nil
      results.each { |s|
        ChoiceEngine::LastId.first.update(last_reply_id: s.id)
        @current_tweet = s
        yield s
      }
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

  #
  replies do |tweet|
    text = ChoiceEngine::Utils.remove_username_from_text(tweet.text)
    response = ChoiceEngine::Responder.new(text, tweet.user.screen_name).respond
    reply "#USER# #{response}", tweet
  end
else
  message = uptime_messages.sample + " (#{Time.now.utc.to_s})"
  tweet message
end


