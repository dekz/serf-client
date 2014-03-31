# Serf::Client

[Serf](http://serfdom.io) Client RPC for Ruby.  
This is raw, new and guaranteed to be full of bugs.

## Installation

Add this line to your application's Gemfile:

    gem 'serf-client'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install serf-client

## Usage

```ruby
    
    require 'serf/client'
    client = Serf::Client.connect address: '127.0.0.1', port: 7373
    
    # Listen for stream events
    client.stream 'user:deploy' do |response|
      puts response
    end
    
    # Trigger a new user-event in Serf asynchronously
    client.event 'deploy'
    
    # Block till your async is performed
    client.event('deploy').value
    
    # Block until members are returned
    client.members.value

```


Implemented:  

    handshake
    event
    force-leave
    members
    stream
    monitor
    stop
    leave

Not yet implemented:  

    auth
    query
    respond
    join

## Contributing

1. Fork it ( http://github.com/dekz/serf-client/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
