require 'thread_safe'
require 'json'
class R4S
  SSES = ThreadSafe::Hash.new

  def self.add_stream(response,key="none")

    if !R4S::SSES.keys.include?(key)
      R4S::SSES[key] = ThreadSafe::Hash.new
      key_count = 0
    else
      key_count = R4S::SSES[key].keys.count
    end

    sse = R4S::SSE.new(response,key,key_count)
    R4S::SSES[key][key_count] = sse

    return sse

  end

  def self.push_data(key,data,options={})
    if R4S::SSES.keys.include?(key)
      R4S::SSES[key].each do |k,sse|
        sse.write(data,options)
      end
    end
  end

  class SSE

    def initialize response, key, id
      response.headers['Content-Type'] = 'text/event-stream'
      @response = response
      @id = id
      @key = key
      @io = response.stream
    end

    def write object, options = {}
      options.each do |k,v|
        @io.write "#{k}: #{v}\n"
      end
      @io.write "data: #{JSON.dump(object)}\n\n"
    end

    def start
      begin
        while !@io.closed?; 
          sleep 30
        end
      rescue
      ensure
        R4S::SSES[@key][@id].close 
        R4S::SSES[@key].delete(@id)
      end
    end

    def closed?
      @io.closed?
    end

    def close
      @io.close
    end
  end
end
