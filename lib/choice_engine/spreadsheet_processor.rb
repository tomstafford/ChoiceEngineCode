require 'roo'
require_relative 'post.rb'
require_relative 'link.rb'

module ChoiceEngine
  class SpreadsheetProcessor

    attr_accessor :spreadsheet, :sheets

    SPREADSHEET_NAME = '/Users/james/Dropbox/ChoiceEngineBackroom/ChoiceEngineGraph.xlsx'
    SHEETS = ['Posts', 'Links']

    def initialize(spreadsheet = SPREADSHEET_NAME)
      @spreadsheet = Roo::Excelx.new(SPREADSHEET_NAME)
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

    def sheets
      @sheets
    end

    def posts
      @sheets[:posts]
    end

    def links
      @sheets[:links]
    end
  end
end
