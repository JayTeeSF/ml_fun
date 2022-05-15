#!/usr/bin/env ruby

require_relative '../lib/ml_fun'
require_relative '../lib/ml_fun/data_to_arrays.rb'

if __FILE__ == $PROGRAM_NAME
  if ARGV.size >= 2
    model = MlFun::LinearModel.new(ARGV.shift.to_f, ARGV.shift.to_f, 0)
    puts "Using model: #{model.to_h}"
  else
    fail("missing model specifications:\n\t#{$PROGRAM_NAME} <weight> <bias>")
  end

  test_data_path = test_data = x_data = y_data = nil
  if ARGV.size >= 2
    if ARGV[0] == '--test_data_path'
      ARGV.shift
      test_data_path = ARGV.shift
      test_data = MlFun::DataToArrays.new(test_data_path).run
      x_data = test_data[:x]
      y_data = test_data[:y]
    else
      x_data, y_data = *ARGV.partition { |w| w.to_i.even? }
    end
  else
    test_data = MlFun::DataToArrays.new("./data/test_data.txt").run
    x_data = test_data[:x]
    y_data = test_data[:y]
  end
  x_data = x_data.map{|i| i.to_f}
  y_data = y_data.map{|i| i.to_f}

  if y_data
    puts "x_data: #{x_data} => #{model.predict(x_data)} ?= #{y_data}"
  end
end
