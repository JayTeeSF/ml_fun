#!/usr/bin/env ruby

require_relative '../lib/ml_fun'
require_relative '../lib/ml_fun/data_to_arrays'

module MlFun
  class ModelTrainer
    def self.train(iterations=nil, weight=nil, bias=nil, learning_rate=nil, training_data_path: nil, good_enough: nil)
      new(iterations, weight, bias, learning_rate, training_data_path: training_data_path, good_enough: good_enough).train
    end

    DEFAULT_ITERATIONS = 100
    DEFAULT_TRAINING_DATA_PATH = "./data/training_data.txt"
    def initialize(num_iterations=nil, weight=nil, bias=nil, learning_rate=nil, training_data_path: nil, good_enough: nil)
      training_data_path ||= DEFAULT_TRAINING_DATA_PATH
      @training_data_hash  = DataToArrays.new(training_data_path).run
      @num_iterations      = num_iterations || DEFAULT_ITERATIONS
      @weight              = weight
      @bias                = bias
      @learning_rate       = learning_rate
      @good_enough         = good_enough
    end

    def train
      model = LinearlyTrainableModel.new(@weight, @bias, @learning_rate, @good_enough)
      best_model = model
      last_loss = nil
      @num_iterations.times do |n|
        best_model, details = *model.train(@training_data_hash[:x], @training_data_hash[:y], n)

        loss = details[:loss]
        if last_loss && (last_loss == loss) # stop if the loss isn't improving!
          warn("loss isn't improving")
          break
        end
        if (n % 100 == 0)
          last_loss = loss
        end

        warn details
        model = best_model
      end
    rescue Exception => e
      warn(%Q|Exception: #{e.message}; bkt: #{e.backtrace.join("\n\t")}|)
    ensure
      return best_model
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  arg_value_for = {'--iterations' => {value: nil, format: :to_i},'--weight' => {value: nil, format: :to_f}, '--bias' => {value: nil, format: :to_f}, '--learning_rate' => {value: nil, format: :to_f}, '--training_data_path' => {value: nil, format: :to_s}, '--good_enough' => {value: nil, format: :to_f}}
  matched = false
  while ARGV.size > 0
    if arg = arg_value_for.keys.detect {|k| ARGV[0] == k}
      ARGV.shift
      arg_value_for[arg][:value] = ARGV.shift.send(arg_value_for[arg][:format])
      matched = true
    end
    break unless matched
    matched = false
  end
  model = MlFun::ModelTrainer.train(
    arg_value_for['--iterations'][:value],
    arg_value_for['--weight'][:value],
    arg_value_for['--bias'][:value],
    arg_value_for['--learning_rate'][:value],
    training_data_path: arg_value_for['--training_data_path'][:value],
    good_enough: arg_value_for['--good_enough'][:value]
  )
  puts "Resulting model: #{model.to_h}"
end
