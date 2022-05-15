require_relative './model.rb'
require_relative './vector.rb'

module MlFun
  class LinearModel < Model
    attr_reader :w, :b, :lr
    def initialize(w=nil, b=nil, lr=nil, good_enough=nil)
      @w           = w  || rand
      @b           = b  || rand
      @lr          = lr || rand * 0.1
      @good_enough = good_enough # no default
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
      @lr == 0 ? {w: @w, b: @b} : {w: @w, b: @b, lr: @lr}
    end
  end
end
