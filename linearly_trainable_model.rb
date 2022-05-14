class LinearlyTrainableModel < LinearModel
  def avg(scalar_or_vector)
    vos = Vector.maybe(scalar_or_vector)
    vos.respond_to?(:average) ?  vos.average : vos
  end

  def sq_loss(guess, actual)
    Vector.maybe(Vector::VV.maybe(actual) - Vector::VV.maybe(guess)) ** 2
  end

  def adjustment(guess,y)
    # if sq_loss is a vector ...use it's average...
    value = @lr * avg(sq_loss(guess,y))
    raise("illegal adjustment: #{value.inspect}") if value <= 0
    value
  end

  # input x and y as scalars (or vectors)
  def train(x, y)
    details = {
      starting_w: @w,
      starting_b: @b,
      learning_rate: @lr,
      input: x, # might be a vector
      correct_answer: y # might be a vector
    }

    prediction = predict(x, @w, @b)
    details[:prediction] = prediction # might be a vector
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
    raise("DONE: already converged") if minimum_loss == adjustment
    # grab the value from the array returned
    best_obj = weighted_object.detect { |k, _| k == minimum_loss }.last
    #it is the object with the minimum loss...

    details[:adjustment] = adjustment
    details[:new_w] = best_obj.w
    details[:new_b] = best_obj.b

    return [best_obj, details]
  end
end
