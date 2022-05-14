#!/usr/bin/env ruby

require_relative './data_to_arrays.rb'
require_relative './linear_model.rb'
require_relative 'linearly_trainable_model.rb'

class ModelTrainer
  def self.train(iterations=nil, weight=nil, bias=nil)
    new(iterations, weight, bias).train
  end

  DEFAULT_ITERATIONS = 10_000
  def initialize(num_iterations=nil, weight=nil, bias=nil)
    @data_hash = DataToArrays.new.run
    @num_iterations = num_iterations || DEFAULT_ITERATIONS
    @weight = weight
    @bias = bias
  end

  def train
    model = LinearlyTrainableModel.new(@weight, @bias)
    best_model = model
    @data_hash[:x].each.with_index do |x, idx|
      @num_iterations.times do |n|
        best_model, details = *model.train(x, @data_hash[:y][idx])
        puts "iteration: #{n}[idx: #{idx}: #{details}"
        model = best_model
      end
    end
  rescue Exception => e
    warn(%Q|Exception: #{e.message}; bkt: #{e.backtrace.join("\n\t")}|)
  ensure
    return best_model
  end
end

if __FILE__ == $PROGRAM_NAME
  iterations = weight = bias = nil
  if ARGV[0] == '--iterations'
    ARGV.shift
    iterations = ARGV.shift.to_i
  end
  if ARGV[0] == '--weight'
    ARGV.shift
    weight = ARGV.shift.to_f
  end
  if ARGV[0] == '--bias'
    ARGV.shift
    bias = ARGV.shift.to_f
  end
  model = ModelTrainer.train(iterations, weight, bias)
  puts "Resulting model: #{model.to_h}"

  ary = ARGV
  unless ARGV.size > 0
    ary = [7, -1]
  end
  ary.each do |x_val|
    puts "#{x_val} => #{model.predict(x_val.to_f)}"
  end
end
