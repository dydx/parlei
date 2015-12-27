Parlei
---------
Parlei is a very basic demonstration of my attempts to work out an event-sourced Ruby application. It uses Sinatra for a web server, NSQ for a message queue, and uses two watcher daemons to control flow of information to and from the client.

> Demo
> ![Demo](http://g.recordit.co/fpz0vP62C8.gif)

-----------
## Boundaries
There are two distinct boundaries in the architecture to explore:

* Incoming information
* Information retrieval

### Incoming Information
The simple interface delivered by Sinatra serves as the information collection point. Specifically, an HTML form sends entered messages to the server via AJAX POST requests.

Messages are then shoved into the `messages` NSQ stream. Messages are then pulled from the `messages` stream, serialized, and pushed into a log. An example of how these serialized messages would appear in the database is as follows:

> Example Audit Log (parsed with Parslet):
>```
> CreateUserEvent, id: 1, username: testUser, password: 1245
> CreateUserEvent, id: 2, username: testUser2, password: 6789
> CreatePostEvent, id: 1, user_id: 1, body: "hey how's it going?"
> CreatePostEvent, id: 2, user_id: 2, body: "not much, you?"
> CreatePostEvent, id: 3, user_id: 1, body: "about the same"
> CreatePostEvent, id: 4, user_id: 2, body: "alright. talk later?"
> CreatePostEvent, id: 5, user_id: 1, body: "yeah, totally"
> ...
>```
> *Note: the password field here is in plaintext, in general it would actually be encrypted*

Whether these serialized messages are generated on the client or on the server are a matter of implementation-- as it is in my demonstration, they are generated on the server.

The log where these messages end up can be anywhere, from a text file, to a database, or even in memory.

Information in the audit log is also immutable; there exist no operations to remove an entry from the log, and tampering with the continuity or integrity of the log will raise tampering flags.

### Information Retrieval
Once messages are stored in the master audit log, there is a daemon that watches for changes and is capable of then updating projections and snapshots of the data. These processed representations of the data are then able to be stored for fast retrieval, and can be held anywhere from a text file, a database, or in memory.

Projections and snapshots can be thought of as an aggregate of all previous events, much like how a final balance of a bank ledger is calculated.

Projections can also be generated as separate processes and can pipe back into the message queue if needed to. Projections can be used for things such as:

* Data display on the client
* Analytics for operations
* Analytics for marketing/advertising (in the case of ecommerce, perhaps)
* etc

Using a database capable of streaming, one can push updates to projections in realtime. See RethinkDB's `changefeed` feature for some inspiration about how to do this.

At this point in time, my only projection is a view of the last five events:

> event_parser.rb
> ```
> require 'nsq'
> require './event'
> 
> class FiveLatestProjection < Event::Projection
>   # There should be a more elegant way to handle this, but so far so good?
>   def initialize
>     super('127.0.0.1:4150', 'events')
>   end
> 
>   def run
>     previous_push = []
>     loop do
>       # I'd like to keep this information somewhere else
>       # and make it a tad more agnostic about where the data
>       # itself comes from. Right now this is very FS specific
>       log = File.open('logs/master_audit.log', 'r').to_a
>       current_push = (log.size >= 5 ? log[log.size - 5, log.size] : log)
>       # current_push = Hash[raw_data.each_with_index.map { |val, index| [index, val] } ]
>       # current_push = log[log.size - 5, log.size]
> 
>       unless current_push == previous_push
>         # this is where content is written to the queue
>         write(current_push)
> 
>         # this prevents us from overloading the channel with old data
>         previous_push = current_push
>       end
>       sleep 2.0
>     end
>   end
> end
> 
> projection = FiveLatestProjection.new
> projection.run
> ```

Adapting this "formula" to create more projection channels should be trivial

----------
# Setup
> **Requirements**
> Parlei has two main requirements:
> * NSQ
> * Ruby 2.2.*+

## Running the demo

1. `git clone https://github.com/dydx/parlei`
2. `cd parlei`
3. `bundle install`
4. `foreman start`

> **A Word On Foreman**
>The Foreman `Procfile` included is configured to start NSQ, the Sinatra webapp, as well as the two watcher daemons.

From there you should be able to visit the webapp in your browser (likely at http://localhost:5300)

Typing into the form and submitting should cause the array shown underneath to update with the five newest messages.

This array can also be viewed in the browser console. 

---------
# TODO
There's a whole lot left to do...

* Modularize the components into separate `gems` and have them be provided through `Bundler`.
* Abstract the creation of `Projections` to a DSL or something.
* Abstract the creation of `Event Models`
* Create adapters for more than just text files
	* This is largely contingent on the DSL I have for storing events
* Create adapters for different message queues (such as Resque) 
* Lots of things I probably haven't considered yet.

----------
# Neat Stuff

## Models
I am also working on a DSL to specify what I call `Event Models`, which auto-generate `Attribute Events`.

I already have a working parser for the DSL described in the Incoming Information section. Right now I am focusing some attention on how to evaluate these instructions.

Ideally, an Event Model can be specified like so:


> post.rb
> ```
> class Post < Events::Base
>   int :id
>   int :user_id
>   string :body
>   datetime :true
> end 
> ```

These Event Models then enable generation of Attribute Events such as: `CreatePostEvent`, `ModifyBodyEvent` and `DeletePostEvent`.

Instead of making destructive operations on the log, which is impossible, Attribute Events just update the state of the stored items.

It might be worth exploring the idea of whitelisting Attribute Event creation, so as to keep some aspects of state like database indicies as truly immutable.

## Server Sent Events
I was also able to leverage Server Sent Events for a sort of one-way data-binding from NSQ/Sinatra to the JavaScript frontend.

With this, clients are stored in a client pool and messages are piped to each connected client asynchronously. The effect is a sort of real-time mechanism, and I'm really happy with how it works.

## Foreman
Foreman is awesome. If you aren't using it, you should.

--------

# License


>The MIT License (MIT)
Copyright © 2015 Joshua Sandlin <<josh@thenullbyte.org>>

>Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

>The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

>THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
