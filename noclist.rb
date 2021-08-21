#!/usr/bin/env ruby
require_relative './lib/badsec'
require 'json'

class Noclist
  def self.print_noclist
    begin
      badsec = BADSEC_API_Client.new
      noclist = badsec.get_noclist
      puts noclist.to_json
      return true
    rescue API_Error => e
      $stderr.puts e
      return false
    end
  end
end

if $PROGRAM_NAME == __FILE__
  if Noclist.print_noclist
    exit 0
  else
    exit 1
  end
end
