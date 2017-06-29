#!/usr/bin/env ruby
require 'rubygems'
require 'dotenv'
require 'awesome_print'
require_relative 'choice_engine/responder.rb'

Dotenv.load('../.env')

require_relative 'chatterbox_config'

#
# this block responds to mentions of your bot
#
replies do |tweet|
  text = extract_actual_message(tweet.text)
  response = ChoiceEngine::Responder.new(text).respond
  reply "#USER# #{response}", tweet
end

def extract_actual_message(text)
  text = text.dup if text.frozen?
  text.slice! "@choiceengine"
  text.slice! "@ChoiceEngine"
  text.slice! "@Choiceengine"
  text
end
