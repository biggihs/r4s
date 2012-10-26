require "r4s/version"

module R4S
  class SSE
    def initialize io
      @io = io
    end

    def write object, options = {}
      options.each do |key,value|
        @io.write "#{key}: #{value}"
      end
      @io.write "data: #{JSON.dump(object)}\n\n"
    end

    def close
      @io.close
    end
  end
end
