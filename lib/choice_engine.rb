#!/usr/bin/env ruby
require 'rubygems'
require 'dotenv'

Dotenv.load('../.env')

require_relative 'chatterbox_config'

#
# this block responds to mentions of your bot
#
replies do |tweet|
  # replace the incoming username with #USER#, which will be replaced
  # with the handle of the user who tweeted us by the
  # replace_variables helper
  src = tweet.text.gsub(/@ChoiceEngine/, "#USER#")

  # send it back!
  reply src, tweet
end
