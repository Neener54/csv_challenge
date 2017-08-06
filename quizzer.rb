#!/usr/bin/env ruby
# encoding: utf-8
require 'pathname'
require 'csv'
require 'pry'

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
  question = {
      strand_id:           row['strand_id'],
      strand_name:         row['strand_name'],
      standard_id:         row['standard_id'],
      standard_name:       row['standard_name'],
      question_id:         row['question_id'],
      question_difficulty: row['difficulty']
  }
  @questions << question
  @used_questions << question
end

def frequency(obj)
  obj.inject(Hash.new(0)) { |h,v| h[v.to_i] += 1; h }
end

def lowest(arr)
  return 1 if arr.empty?
  freq = frequency(arr)
  freq.min_by(&:last)
end

def lowest_strand
  strands = @used_questions.map { |question| question[:strand_id] }
  lowest(strands)
end

# def lowest_standard
#   lowest(@standards)
# end
#
# def lowest_question
#   lowest(@used_questions)
# end

def add_question(output, questions)
  question = questions.sample(1)[0]
  unless @used_questions.include?(question) && question[:strand_id] == lowest_strand
    @used_questions << question
    output << question
  end
end

output = []
while output.length < question_count.to_i do
  add_question(output, @questions)
end

puts "#{output.map { |o| o[:question_id] }.join(',')}"
CSV.open('./usage.csv', 'wb') do |csv|
  csv << ['question_id']
  output.each { |question| csv << [question[:question_id]] }
end


