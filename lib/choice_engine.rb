#!/usr/bin/env ruby
require 'rubygems'
require 'dotenv'
require 'awesome_print'

Dotenv.load('../.env')

require_relative 'chatterbox_config'

#
# this block responds to mentions of your bot
#
replies do |tweet|
  response = get_response(tweet.text)
  reply "#USER# #{response}", tweet
end

def get_response(text)
  text = text.dup if text.frozen?
  text = extract_actual_message(text)
  text.reverse
end

def extract_actual_message(text)
  text = text.dup if text.frozen?
  text.slice! "@choiceengine"
  text.slice! "@ChoiceEngine"
  text.slice! "@Choiceengine"
  text
end
