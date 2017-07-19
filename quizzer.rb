#!/usr/bin/env ruby
# encoding: utf-8
require 'pathname'
require 'csv'

class QuestionCountError < StandardError
end

# This application has too much state. I need to figure out how to shrink that

question_count = ARGV[0]
@used_questions = []
@strands = []
@standards = []
@question_ids = []
raise(QuestionCountError.new("Question Count must be a positive integer, got #{question_count}")) unless question_count.to_i > 0

questions = []
CSV.foreach('questions.csv', headers: true) do |row|
  @strands << row["strand_id"].to_i
  @standards << row["standard_id"].to_i
  @used_questions << row["question_id"].to_i
  questions << {
      strand_id:   row["strand_id"],
      strand_name: row["strand_name"],
      standard_id:       row["standard_id"],
      standard_name:     row["standard_name"],
      question_id:         row["question_id"],
      question_difficulty: row["difficulty"]
  }
end

def frequency(obj)
  obj.inject(Hash.new(0)) { |h,v| h[v.to_i] += 1; h }
end

def lowest(arr)
  return 1 if arr.empty?
  freq = frequency(arr)
  arr.min_by { |v| freq[v].to_i }.to_i
end

def lowest_strand
  lowest(@strands)
end

def lowest_standard
  lowest(@standards)
end

def lowest_question
  lowest(@used_questions)
end

# My logic is flawed here, there's obviously cases where the lowest of each won't exist in the array, I should
# be looking through the questions and finding the strands that haven't been used, then checking for the standards
# then checking the questions.
def add_question(output, questions)
  question_to_add = questions.find do |question|
    question[:strand_id].to_i == lowest_strand &&
        question.dig(:standard_id).to_i == lowest_standard &&
        question.dig(:question_id).to_i == lowest_question
  end
  return if question_to_add.nil?
  output << question_to_add
  @strands << question_to_add[:strands_id]
  @standards << question_to_add.dig(:standard_id)
  @used_questions << question_to_add.dig(:question_id)
end

output = []
question_count.to_i.times do
  add_question(output, questions)
end
puts output.map{|o| o[:question_id]}
CSV.open("./usage.csv", "wb") do |csv|
  csv << ["question_id"]
  output.each {|o| csv << [o[:question_id]]}
end


