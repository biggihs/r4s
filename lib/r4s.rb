require 'thread_safe'
require 'json'

#TODO:: Figure out if there is ANY way to share a sse-connection (true broadcast)
module R4S
  #SSES Is a global hash that stores all the sse-connections. Accessable between threads.
  #Format: SSES["key"]["session.id"][#number]
  #      : The #number is because a user might open the same page in two tabs, in which 
  #      : the browser needs a sse-connection for each tab.
  SSES = ThreadSafe::Hash.new

  #The key is used to group "identical" sse-streams so you can push data to a group of streams
  #The session_id is used to identify users who already have a connection
  def self.add_stream(response,session,key="none")

    id = session["session_id"]

    unless R4S::SSES.keys.include?(key)
      R4S::SSES[key] = ThreadSafe::Hash.new
      R4S::SSES[key][id] = ThreadSafe::Array.new
    end

    sse = R4S::SSE.new(response,key,id)
    R4S::SSES[key][id] << sse

    return sse
  end

  def self.push_data(key,data,options={})
    if R4S::SSES.keys.include?(key)
      R4S::SSES[key].each do |k,client|
        client.each do |sse|
          sse.write(data,options)
        end
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
          sleep 10  #I don't know if this is a good idea or if I should skip "sleep" entirely.
          self.write({},{}) # If !@io.closed? gives a false positive then this crashes and forces exit
        end
      rescue
      ensure
        R4S::SSES[@key][@id].delete(self)
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
