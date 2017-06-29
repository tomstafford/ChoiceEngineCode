class SpreadsheetProcessor

  attr_accessor :spreadsheet, :sheets

  SPREADSHEET_NAME = '~/Dropbox/ChoiceEngineBackroom/ChoiceEngineGraph.xlsx'
  SHEETS = ['Posts', 'Links']

  def initialize(spreadsheet = SPREADSHEET_NAME)
    @spreadsheet = Roo::Excelx.new(SPREADSHEET_NAME)
    @sheets = {}
  end

  def self.reset
    Post.delete_all
    Link.delete_all
    Extension.delete_all
  end

  def parse
    # Get sheets and iterate over them
    @spreadsheet.each_with_pagename do |name, sheet|
      symbol = name.parameterize.underscore.to_sym
      @sheets[symbol] = sheet.clone
    end
  end

  def create_parts
    taster_part = Part.create(name: 'Taster', position: 0, taster: true, question: 'How often do you want to do these things?')
    create_taster_section(taster_part)

    ['Now','Change','Future'].each_with_index do |part_name, index|
      copy = get_part_copy(part_name)
      question = get_question(part_name)
      part = Part.create!(name: part_name, position: index + 1, copy: add_markup_to_deepsearch(copy), question: question)

      create_steps(part)
    end
  end

  def get_question(part_name)

    front_page_copy_sheet_name = part_name + ' Front Page Copy'
    part_sheet = @sheets[front_page_copy_sheet_name.parameterize.underscore.to_sym]

    last_row = part_sheet.last_row
    part_copy = []

    rows = (0..last_row).map do |row_index|
      row = part_sheet.row(row_index)
      next if row[0].nil?

      if row[0] == 'Question'
        return row[2]
      end
    end
  end

  def get_part_copy(part_name)
    front_page_copy_sheet_name = part_name + ' Front Page Copy'
    part_sheet = @sheets[front_page_copy_sheet_name.parameterize.underscore.to_sym]

    last_row = part_sheet.last_row
    part_copy = []

    rows = (0..last_row).map do |row_index|
      row = part_sheet.row(row_index)
      next if row[0].nil?

      if list?(row)
        part_copy << "* #{row[2]}"
      elsif numbered_list?(row)
        part_copy << "@ #{row[2]}"
      elsif copy?(row, part_name)
        if emphasis?(row)
          part_copy << "! #{row[2]}"
        else
          part_copy << row[2]
        end
      end
    end

    mark_up_copy(part_copy)

  end

  # Basically look through if you see a * it's an unordered list
  # If you see an @ it's an ordered list
  # If you see a ! it's an h2
  def mark_up_copy(copy)
    output = ""

    doing_ul_list = false
    doing_ol_list = false

    copy.each do |item|
      if item.start_with?('*')
        if doing_ul_list == false
          output << '<ul>'
          doing_ul_list = true
        end
        output << "<li>#{item.delete!('*')}</li>"

      elsif item.start_with?('@')
        if doing_ol_list == false
          output << '<ol>'
          doing_ol_list = true
        end
        output << "<li>#{item.delete!('@')}</li>"


      else
        if doing_ul_list
          output << '</ul>'
          doing_ul_list = false
        end

        if doing_ol_list
          output << '</ol>'
          doing_ol_list = false
        end

        if item.start_with?('!')
          output << "<h2>#{item.delete!('!')}</h2>"
        else
          output << "<p>#{item}</p>"
        end
      end
    end
    output
  end

  def create_taster_section(part)
    section = Step.create!(name: part.name, part: part, taster: true, position: 0)
    create_section(part, section, :taster_questions, true)
  end

  def create_steps(part)

    STEPS.each_with_index do |section_name, index|
      step_symbol = section_name.parameterize.underscore.to_sym
      step = Step.create!(name: "Looking #{section_name}", part: part, position: index + 1)
      create_section(part, step, step_symbol)
    end
  end

  def create_section(part, step, step_symbol, taster = false)
    puts "Create  section for #{part.name} - #{step.name} - #{step_symbol}"
    section_sheet = @sheets[step_symbol]
    last_row = section_sheet.last_row

    section = nil
    section_copy = []
    rows = (0..last_row).map do |row_index|

      row = section_sheet.row(row_index)
      next if row[0].nil?

      if section_title?(row)
        # ap "question position #{row[1]} question #{row[2]}"
        section = Section.create!(name: row[2], taster: taster, position: row[1], part: part, step: step)
      elsif questions?(row)
        # ap "#{part.name} - #{section.name} - #{section.name} - #{row[1]} #{row[2]}"
        question_text = row[2]

        # With Rails 5 use String#upcase_first
        question_text = question_text.upcase_first.clone
  #question_text[0] = question_text[0].upcase

        Question.create!(part: part, step: step, section: section, position: row[1], name: question_text)
      elsif copy?(row, part.name)

        if emphasis?(row)
          section_copy << "<h2>#{row[2]}</h2>"
        else
          section_copy << "<p>#{row[2]}</p>"
        end
      end
    end
    step.update!(copy: add_markup_to_deepsearch(section_copy))
  end

  def add_markup_to_deepsearch(copy_array)
    if copy_array.is_a? Array
      copy_array.each do |copy|
        copy = actual_add(copy)
      end
    else
     copy = actual_add(copy_array)
    end
    copy_array
  end

  def actual_add(copy_string)
    if copy_string.downcase.include? 'deep search'
        copy_string.gsub! " Deep Search: Change's",  ' <i>Deep Search: Future</i>'
        copy_string.gsub! " Deep Search: Future's",  ' <i>Deep Search: Future</i>'
        copy_string.gsub! " Deep Search: Now's",     ' <i>Deep Search: Future</i>'
        copy_string.gsub! ' Deep Search: Now',       ' <i>Deep Search: Now</i>'
        copy_string.gsub! ' Deep Search: Change',    ' <i>Deep Search: Change</i>'
        copy_string.gsub! ' Deep Search: Future',    ' <i>Deep Search: Future</i>'
        copy_string.gsub! ' Deep Search',    ' <i>Deep Search</i>'
    end
    copy_string
  end

  def section_title?(row)
    row[0] == 'Sub-section-title'
  end

  def questions?(row)
    row[0].include?('Question')
  end

  def copy?(row, part_name)
    row[0] == 'Copy' || row[0] == "Copy #{part_name}"
  end

  def emphasis?(row)
    row[1] == 'E'
  end

  def list?(row)
    row[0] == 'List'
  end

  def numbered_list?(row)
    row[0] == 'Numbered List'
  end

  def sheets
    @sheets
  end
end
