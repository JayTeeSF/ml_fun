#!/usr/bin/env ruby

require_relative './model.rb'
require_relative './vector.rb'

class LinearModel < Model
  attr_reader :w, :b, :lr
  def initialize(w=nil, b=nil, lr=nil)
    @w  = w  || rand
    @b  = b  || rand
    @lr = lr || rand * 0.1
  end

  # input x as a scalar or a "vector"
  # output y as a scalar or a "vector"
  def predict(x, w=@w, b=@b)
    y = Vector::VS.maybe(Vector::VS.maybe(x) * w) + b # the (potential) vector has to go first...
    return y
  rescue Exception => e
    warn(%Q|x: #{x.inspect}, w: #{w.inspect}, b: #{b.inspect}; Exception: #{e.message}, bkt: #{e.backtrace.join("\n\t")}|)
    raise(e)
  end

  def to_h
    {w: @w, b: @b, lr: @lr}
  end
end

if __FILE__ == $PROGRAM_NAME
  if ARGV[0] =~ /^\d/ 
    model = LinearModel.new(ARGV.shift.to_f, ARGV.shift.to_f)
    puts "Using model: #{model.to_h}"
  else
    fail("missing model specifications:\n\t#{$PROGRAM_NAME} <weight> <bias>")
  end

  ary = ARGV
  unless ARGV.size > 0
    ary = [7, -1]
  end
  ary.each do |x_val|
    puts "#{x_val} => #{model.predict(x_val.to_f)}"
  end
end
