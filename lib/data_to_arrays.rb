#!/usr/bin/env ruby

require 'json'
class DataToArrays
  def initialize(input_path)
    @input_path = input_path
  end

  def run
    raw_data = File.readlines(@input_path)
    x_data = JSON.parse(raw_data.first.split("X:").last)
    y_data = JSON.parse(raw_data.last.split("Y:").last)
    return {x: x_data, y: y_data}
  end
end

if __FILE__ == $PROGRAM_NAME
  puts DataToArrays.new().run
end
