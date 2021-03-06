require 'roo'
require_relative 'activerecord_models/post.rb'
require_relative 'activerecord_models/link.rb'

module ChoiceEngine
  class SpreadsheetProcessor
    attr_reader :spreadsheet, :sheets

    SHEETS = %w(Posts Links).freeze

    def initialize
      @spreadsheet = Roo::Excelx.new(ENV['SPREADSHEET_PATH_NAME'])
      @sheets = {}
    end

    def self.reset
      Post.delete_all
      Link.delete_all
    end

    def parse
      # Get sheets and iterate over them
      @spreadsheet.each_with_pagename do |name, sheet|
        symbol = name.downcase.to_sym
        @sheets[symbol] = sheet.clone
      end
    end

    def import_posts
      posts.each(title: 'Title', description: 'TwitterDescriptions', url: 'URL', start: 'Start', end: 'End', importance: 'Importance') do |hash|
        unless hash[:title] == 'Title'
          Post.create(hash)
        end
      end
    end

    def import_links
      links.each(post_title: 'PostTitle', abbreviation: 'LinkAbbreviation', outgoing_post_title: 'LinkDestination') do |hash|
        unless hash[:post_title] == 'PostTitle'
          post = Post.find_by(title: hash[:post_title])
          if post
            p "Found post for #{hash[:post_title]}"
            outgoing_post = Post.find_by(url: hash[:outgoing_post_title])
            if outgoing_post
              p "Found outgoing_post for #{hash[:outgoing_post_title]}"
              Link.create(post_id: post.id, abbreviation: hash[:abbreviation], outgoing_post_id: outgoing_post.id)
            else
              p "cannot find outgoing post id for #{hash[:outgoing_post_title]}"
            end
          else
            p "cannot find post id for #{hash[:post_title]}"
          end
        end
      end
    end

    def posts
      @sheets[:posts]
    end

    def links
      @sheets[:links]
    end
  end
end
