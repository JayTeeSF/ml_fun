#!/usr/bin/env ruby

require_relative './data_to_arrays.rb'

class Model
  attr_reader :w, :b, :lr
  def initialize(w=rand, b=rand, lr=rand * 0.1)
    @w  = w
    @b  = b
    @lr = lr
  end

  def to_s
    to_h.inspect
  end

  def sq_loss(guess, actual)
    (actual - guess) ** 2
  end

  def to_h
    {w: @w, b: @b, lr: @lr}
  end

  def adjustment(guess,y)
    value = @lr * sq_loss(guess,y)
    raise("illegal adjustment: #{value.inspect}") if value <= 0
    value
  end

  def train(x, y)
    details = {
      starting_w: @w,
      starting_b: @b,
      learning_rate: @lr,
      input: x,
      correct_answer: y
    }

    prediction = predict(x, @w, @b)
    details[:prediction] = prediction
    adjustment = adjustment(prediction,y)

    # make new model(s)

    # add all options to the hash: think truthtable for adjusting w & b
    #
    model_choices = [
      self.class.new(@w + adjustment, @b, @lr),
      self.class.new(@w - adjustment, @b, @lr),

      self.class.new(@w, @b + adjustment, @lr),
      self.class.new(@w, @b - adjustment, @lr),

      self.class.new(@w + adjustment, @b + adjustment, @lr),
      self.class.new(@w - adjustment, @b - adjustment, @lr),

      self.class.new(@w + adjustment, @b - adjustment, @lr),
      self.class.new(@w - adjustment, @b + adjustment, @lr),

      self.class.new(@w, @b, @lr),
    ]
    weighted_object = model_choices.reduce({}) {|m,o| m[o.adjustment(o.predict(x, o.w, o.b),y)] = o;m}

    minimum_loss = weighted_object.keys.min
    raise("already converged") if minimum_loss == adjustment
    # grab the value from the array returned
    best_obj = weighted_object.detect { |k, _| k == minimum_loss }.last
    #it is the object with the minimum loss...

    details[:adjustment] = adjustment
    details[:new_w] = best_obj.w
    details[:new_b] = best_obj.b

    return [best_obj, details]
  end
end

class LinearModel < Model
  def predict(x, w=@w, b=@b)
    y = w * x + b
    return y
  end
end

class ModelTrainer
  def self.train(iterations=nil)
    new(iterations).train
  end

  DEFAULT_ITERATIONS = 10
  def initialize(num_iterations=nil)
    @data_hash = DataToArrays.new.run
    @num_iterations = num_iterations || DEFAULT_ITERATIONS
  end

  def train
    model = LinearModel.new()
    best_model = model
    @data_hash[:x].each.with_index do |x,idx|
      @num_iterations.times do |n|
        best_model, details = *model.train(x, @data_hash[:y][idx])
        puts details
        model = best_model
      end
    end
  rescue Exception => e
    true
  ensure
    return best_model
  end
end

if __FILE__ == $PROGRAM_NAME
  if ARGV[0] =~ /^\d/ 
    model = LinearModel.new(ARGV.shift.to_f, ARGV.shift.to_f)
    puts "Using model: #{model.to_h}"
  else
    iterations = nil
    if ARGV[0] == '--iterations'
      ARGV.shift
      iterations = ARGV.shift.to_i
    end
    model = ModelTrainer.train(iterations)
    puts "Resulting model: #{model.to_h}"
  end

  ary = ARGV
  unless ARGV.size > 0
    ary = [7, -1]
  end
  ary.each do |x_val|
    puts "#{x_val} => #{model.predict(x_val.to_f)}"
  end
end
