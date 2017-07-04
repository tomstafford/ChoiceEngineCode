#!/usr/bin/env ruby
require 'rubygems'
require 'dotenv'
require 'awesome_print'
require_relative 'choice_engine/responder.rb'
require_relative 'choice_engine/utils.rb'
require_relative 'database_config.rb'

Dotenv.load('../.env')

require_relative 'chatterbox_config'

#
# this block responds to mentions of your bot
#
replies do |tweet|
  text = ChoiceEngine::Utils.remove_username_from_text(tweet.text)
  response = ChoiceEngine::Responder.new(text, tweet.user.screen_name).respond
  reply "#USER# #{response}", tweet
end


