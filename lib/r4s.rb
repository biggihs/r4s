require 'thread_safe'
require 'json'
module R4S
  SSES = ThreadSafe::Hash.new

  #The session_id is used to identify users who already have a connection
  #The key is used to group "identical" sse-streams so you can push data to a group of streams
  def self.add_stream(response,session,key="none")

    id = session["session_id"]

    R4S::SSES[key] = ThreadSafe::Hash.new unless R4S::SSES.keys.include?(key)

    if R4S::SSES[key].keys.include?(id)
      sse = R4S::SSES[key][id]
      sse.close
    end

    sse = R4S::SSE.new(response,key,id)
    R4S::SSES[key][id] = sse

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
        #it might have been reopened
        unless !R4S::SSES[@key][@id].closed?
          R4S::SSES[@key].delete(@id)
        end
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
