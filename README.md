# Noclist

## Retrieve the NOC list

Retrieves the user ID list from the BADSEC server and outputs it in JSON format.

## Requirements

This code is implemented in Ruby 3.0.2.

It is designed to be run in either of two environments: 

1. A local Ruby 3.0.2 installation, or
2. Inside of a locally running Docker host.

In either case, this code expects that the BADSEC server is reachable at localhost:8888.

## Setup

### Local Ruby: 

Confirm Ruby version: `ruby --version` should output a string beginning with `ruby 3.0.2`

Ensure that the necessary Rubygems are available by running `bundle install`

### Docker Ruby:

The provided Dockerfile utilizes the standard Ruby 3.0.2 image. 

The container can be built with the command `docker build -t noclist .`

## Running the Code

First, start the BADSEC server. The development reference version of this server can be
initialized with `docker run --rm -p 8888:8888 adhocteam/noclist`. Starting the test/production
version will likely differ, but it must still be running at localhost:8888.

The step depends on Ruby environment:

### Local Ruby

`./noclist.rb`

### Docker Ruby

`docker run -it --network="host" noclist`

### Expected Behavior and Output

If the interaction with the BADSEC server was successful, the only output will be the 
list so user IDs that server provided, formatted as JSON. Execution will terminate with 
an exit code of 0.

If the server timed out, returned HTTP status codes other than 200, or raised other errors
on three consecutive attempts to either of the two API endpoints it relies on then the 
most recent cause of failure will be reported at stderr. Nothing will be output to stdout.
Execution will terminate with an exit code of 1.

## Testing the Code

The test suite relies on RSpec. It can be invoked in either Ruby environment: 

### Local Ruby

`bundle exec rspec`

### Docker Ruby

`docker run -it testapp bundle exec rspec`
