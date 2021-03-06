# avoid adding training methods directly to the LinearModel
# that way, the LinearModel can be fast for predictions!
module MlFun
  class LinearlyTrainableModel < LinearModel
    ONE_MINUS_SIX_NINES = 1.0000000000287557e-06
    ONE_MINUS_THREE_NINES = 0.0010000000000000009
    def self.nudge(num)
      new_num = num
      incr = num.ceil.to_f
      floor = num.floor.to_f
      if incr - num <= ONE_MINUS_THREE_NINES
        new_num = incr
      elsif num - floor <= ONE_MINUS_THREE_NINES
        new_num = floor
      end
      return new_num
    end 

    attr_reader :lr
    def initialize(w=nil, b=nil, lr=nil, good_enough=nil, debug: false)
      super(w,b)
      @lr          = lr || rand * 0.1
      @good_enough = good_enough # no default
      @debug       = debug
    end

    def nudged_w
      self.class.nudge(@w)
    end

    def nudged_b
      self.class.nudge(@b)
    end

    def debug?
      !!@debug
    end

    def to_h
      {w: @w, b: @b, lr: @lr}
    end

    def adjustment(avg_sq_loss)
      value = @lr * avg_sq_loss
      raise("illegal adjustment: #{value.inspect}") if value <= 0
      value
    end

    def done?(x, y, prediction=predict(x,@w,@b), avg_sq_loss=avg(sq_loss(prediction,y)))
      [Float::INFINITY,Float::NAN].include?(avg_sq_loss) || (@good_enough && (avg_sq_loss <= @good_enough))
    end

    def raw_loss(guess, actual)
      Vector.maybe(
        Vector::VV.maybe(guess) - Vector::VV.maybe(actual)
      )
    end

    def sq_loss(guess, actual)
      raw_loss(guess, actual) ** 2
    end

    def use_gradient_descent?
      #false # slower
      true # faster
    end

    def avg(scalar_or_vector)
      vos = Vector.maybe(scalar_or_vector)
      vos.respond_to?(:average) ?  vos.average : vos
    end

    # input x and y as scalars (or vectors)
    def train(x, y, i)
      details = {
        iteration: i,
      }
      details.merge!({
        starting_w: @w,
        starting_b: @b,
        learning_rate: @lr,
        input: x, # might be a vector
        actual: y # might be a vector
      }) if debug?

      best_obj = self
      prediction = predict(x, @w, @b)
      avg_sq_loss = avg(sq_loss(prediction,y))
      raise("past done") if done?(x, y, prediction, avg_sq_loss)

      details[:loss] = avg_sq_loss
      details[:guess] = prediction if debug?
      if use_gradient_descent?
        raw_loss = raw_loss(prediction,y)
        w_gradient = 2 * avg(Vector::VV.maybe(x) * raw_loss)
        b_gradient = 2 * avg(raw_loss)
        #details[:w_grad] = w_gradient
        #details[:b_grad] = b_gradient
        new_w = @w - w_gradient * @lr
        new_b = @b - b_gradient * @lr
        details[:new_w] = new_w
        details[:new_b] = new_b
        best_obj = self.class.new(new_w, new_b, @lr)
        raise("converged") if best_obj.done?(x,y)
      else
        adjustment = adjustment(avg_sq_loss)

        # make new model(s)

        # add all options to the hash: think truthtable for adjusting w & b
        #
        # 3**(num_parameters) options
        # presently we have w & b and 3**2 = 9
        # given 10 parameters we're talking 60K model choices
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
        weighted_object = model_choices.reduce({}) {|m,o|
          avg_sq_loss = o.avg(o.sq_loss(o.predict(x, o.w, o.b),y))
          m[o.adjustment(avg_sq_loss)] = o;
          m
        }

        minimum_loss = weighted_object.keys.min
        raise("DONE: already converged") if minimum_loss == adjustment
        # grab the value from the array returned
        best_obj = weighted_object.detect { |k, _| k == minimum_loss }.last
        #it is the object with the minimum loss...
        #details[:adjustment] = adjustment
        if debug?
          details[:new_w] = best_obj.w
          details[:new_b] = best_obj.b
        end
      end

      return [best_obj, details]
    end
  end
end
