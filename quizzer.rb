#!/usr/bin/env ruby
# encoding: utf-8
require 'pathname'
require 'csv'

class QuestionCountError < StandardError
end

# This application has too much state. I need to figure out how to shrink that

question_count  = ARGV[0]
@used_questions = []
@strands        = []
@standards      = []
@question_ids   = []
unless question_count.to_i > 0
  raise(QuestionCountError.new,
        "Question Count must be a positive integer, got #{question_count}")
end

@questions = []
CSV.foreach('questions.csv', headers: true) do |row|
  @strands << row['strand_id'].to_i
  @standards << row['standard_id'].to_i
  @used_questions << row['question_id'].to_i
  @questions << {
    strand_id:           row['strand_id'],
    strand_name:         row['strand_name'],
    standard_id:         row['standard_id'],
    standard_name:       row['standard_name'],
    question_id:         row['question_id'],
    question_difficulty: row['difficulty']
  }
end

def add_question(output, questions)
  question = questions.sample(1)[0]
  unless @used_questions.include?(question)
    @used_questions << question
    output << question
  end
end

output = []
while output.length < question_count.to_i do
  if @used_questions.length == @questions.length
    @used_questions = []
  end
  add_question(output, @questions)
end

puts "#{output.map { |o| o[:question_id] }.join(',')}"
CSV.open('./usage.csv', 'wb') do |csv|
  csv << ['question_id']
  output.each { |question| csv << [question[:question_id]] }
end


