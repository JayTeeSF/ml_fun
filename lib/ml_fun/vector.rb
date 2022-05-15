module MlFun
  class Vector
    def self.maybe(vector_or_scalar, clazz=self)
      vector_or_scalar.respond_to?(:map) ? clazz.new(vector_or_scalar) : vector_or_scalar
    end

    def initialize(data=nil)
      @data = data || []
    end

    def average
      Float(@data.sum) / @data.size
    end

    def **(exponent) # assume scalar exponent
      @data.map {|e| e**exponent}
    end

    def [](idx)
      @data[idx]
    end

    class VV < Vector
      def self.*(data, o)
        data.map.with_index {|e,i| e * o[i]}
      end

      def self.+(data, o)
        data.map.with_index {|e,i| e + o[i]}
      end

      def self.-(data, o)
        data.map.with_index {|e,i| e - o[i]}
      end

      def *(o)
        @data.map.with_index {|e,i| e * o[i]}
      end

      def +(o)
        @data.map.with_index {|e,i| e + o[i]}
      end

      def -(o)
        @data.map.with_index {|e,i| e - o[i]}
      end
    end

    class VS < Vector
      def self.*(data, o)
        data.map {|e| e * o}
      end

      def self.+(data, o)
        data.map {|e| e + o}
      end

      def self.-(data, o)
        data.map {|e| e - o}
      end

      def *(o)
        @data.map {|e| e * o}
      end

      def +(o)
        @data.map {|e| e + o}
      end

      def -(o)
        @data.map {|e| e - o}
      end
    end

    def *(o)
      o.respond_to?(:map) ? VV.*(@data,o) : VS.*(@data,o)
    end

    def +(o)
      o.respond_to?(:map) ? VV.+(@data,o) : VS.+(@data,o)
    end

    def -(o)
      o.respond_to?(:map) ? VV.-(@data,o) : VS.-(@data,o)
    end
  end
end
