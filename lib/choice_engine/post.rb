require 'active_record'

module ChoiceEngine
  class Post < ActiveRecord::Base
    has_many :links

    enum importance: [ :high, :medium, :low ]

    def next_options
      links.pluck(:abbreviation).join(', ')
    end
  end
end
