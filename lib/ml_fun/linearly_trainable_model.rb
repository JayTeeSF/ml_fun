# avoid adding training methods directly to the LinearModel
# that way, the LinearModel can be fast for predictions!
module MlFun
  class LinearlyTrainableModel < LinearModel
    def adjustment(avg_sq_loss)
      value = @lr * avg_sq_loss
      raise("illegal adjustment: #{value.inspect}") if value <= 0
      value
    end

    def done?(x, y, prediction=predict(x,@w,@b), avg_sq_loss=avg(sq_loss(prediction,y)))
      [Float::INFINITY,Float::NAN].include?(avg_sq_loss) || avg_sq_loss <= @good_enough
    end

    def raw_loss(guess, actual)
      Vector.maybe(
        Vector::VV.maybe(actual) - Vector::VV.maybe(guess)
      )
    end

    def sq_loss(guess, actual)
      raw_loss(guess, actual) ** 2
    end

    def use_gradient_descent?
      #false # works
      true # fails
    end

    def avg(scalar_or_vector)
      vos = Vector.maybe(scalar_or_vector)
      vos.respond_to?(:average) ?  vos.average : vos
    end

    # input x and y as scalars (or vectors)
    def train(x, y, i)
      details = {
        #starting_w: @w,
        #starting_b: @b,
        #learning_rate: @lr,
        #input: x, # might be a vector
        iteration: i,
        actual: y # might be a vector
      }

      best_obj = self
      prediction = predict(x, @w, @b)
      avg_sq_loss = avg(sq_loss(prediction,y))
      raise("past done") if done?(x, y, prediction, avg_sq_loss)

      details[:loss] = avg_sq_loss
      details[:guess] = prediction # might be a vector
      if use_gradient_descent?
        raw_loss = raw_loss(prediction,y)
        w_gradient = 2 * avg(Vector::VV.maybe(x) * raw_loss)
        b_gradient = 2 * avg(raw_loss)
      details[:w_grad] = w_gradient
      details[:b_grad] = b_gradient
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
        details[:new_w] = best_obj.w
        details[:new_b] = best_obj.b
      end

      return [best_obj, details]
    end
  end
end
