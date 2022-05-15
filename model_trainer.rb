#!/usr/bin/env ruby

require_relative './data_to_arrays.rb'
require_relative './linear_model.rb'
require_relative 'linearly_trainable_model.rb'

class ModelTrainer
  #.train(iterations, weight, bias, learning_rate, training_data_path: training_data_path)
  def self.train(iterations=nil, weight=nil, bias=nil, learning_rate=nil, training_data_path: nil)
    new(iterations, weight, bias, learning_rate, training_data_path: training_data_path).train
  end

  DEFAULT_ITERATIONS = 10_000
  DEFAULT_TRAINING_DATA_PATH = "./training_data.txt"
  def initialize(num_iterations=nil, weight=nil, bias=nil, learning_rate=nil, training_data_path: nil)
    training_data_path ||= DEFAULT_TRAINING_DATA_PATH
    @training_data_hash = DataToArrays.new(training_data_path).run
    @num_iterations = num_iterations || DEFAULT_ITERATIONS
    @weight = weight
    @bias = bias
    @learning_rate = learning_rate
  end

  def train
    model = LinearlyTrainableModel.new(@weight, @bias, @learning_rate)
    best_model = model
    @num_iterations.times do |n|
      best_model, details = *model.train(@training_data_hash[:x], @training_data_hash[:y])
      puts "iteration: #{n}: #{details}"
      model = best_model
    end
  rescue Exception => e
    warn(%Q|Exception: #{e.message}; bkt: #{e.backtrace.join("\n\t")}|)
  ensure
    return best_model
  end
end

if __FILE__ == $PROGRAM_NAME
  iterations = weight = bias = learning_rate = training_data_path = nil
  matched = false
  while ARGV.size > 0
    if ARGV[0] == '--iterations'
      ARGV.shift
      iterations = ARGV.shift.to_i
      matched = true
    end
    if ARGV[0] == '--weight'
      ARGV.shift
      weight = ARGV.shift.to_f
      matched = true
    end
    if ARGV[0] == '--bias'
      ARGV.shift
      bias = ARGV.shift.to_f
      matched = true
    end
    if ARGV[0] == '--learning_rate'
      ARGV.shift
      learning_rate = ARGV.shift.to_f
      matched = true
    end
    if ARGV[0] == '--training_data_path'
      ARGV.shift
      training_data_path = ARGV.shift
      matched = true
    end
    break unless matched
    matched = false
  end
  model = ModelTrainer.train(iterations, weight, bias, learning_rate, training_data_path: training_data_path)
  puts "Resulting model: #{model.to_h}"
end
