# R4S (Rails 4 Streaming)

R4S is a gem that simplifies sending server side events (SSE) to multiple browsers in Rails 4.
It is supposed to simulate broadcasting to all the browsers that are connected to it.

Here is a ascii picture that shows how a webpage would send a 'update' event to three browsers.

My ASCII Picture. :)

    |---------|                      /-----------> browser0
    | Webpage | --['update']--------|------------> browser1
    |---------|                      \-----------> browser2


Most of my code is based on Tenderloves "Is it live?" article. http://tenderlovemaking.com/2012/07/30/is-it-live.html

## NOTE
This gem works only in Rails 4 (I thinks)

You can not use turbolinks with this project for some strange, inapparent reason. 
If you make a connection and then close the browser the srv will crash stating that the headers had already been sent.
who, why, where or how these headers are sent are a mistery to me. My solution was to remove the turbolinks. 
This might be fixed in the future.

## Installation

Add this line to your application's Gemfile:

    gem 'r4s'

And then execute:

    $ bundle install

## Usage

You'll need a controller that has included `ActionController::Live` to be able to stream.

A page with javascript EventSource to connect to the stream.

And some controller.action to trigger the stream.event.

R4S uses only two functions

One to create the stream(s)

    R4S.add_stream(response,"key").start

One to push to the stream(s)

    R4S.push_data("key",data,options)

## Example
I created a "stream" controller to handle my streams

    class StreamController < ApplicationController
        include ActionController::Live
        def stream1
            R4S.add_stream(response,"stream.key").start
        end
    end

Create a webpage that connects to the stream.
    `app/views/home/show.html.erb`

    <h1>Event Page</h1>
    <p>The time : <span id="time"></span></p>
    <script>
    jQuery(document).ready(function() {
        source = new EventSource('/stream/stream1');
        source.addEventListener('refresh', function(e) {
          var data = JSON.parse(e.data);
          jQuery('#time').html(data["time"]);
        }); 
    });
    </script>

Create a action that triggers the event.

    class HomeController < ApplicationController
      def index
        R4S.push_data('kanban',{:time=>Time.now},:event=>"refresh")
        render :json => {:success=>true}
      end
    
      def show
      end
    end


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
