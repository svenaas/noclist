require 'net/http'
require 'digest'

class API_Error < StandardError
end

class BADSEC_API_Client
  def initialize(server_uri = 'http://localhost:8888')
    uri = URI server_uri
    @service = Net::HTTP.new uri.host, uri.port

    # Net::HTTP retries idempotent requests by default.
    # In this case we need to use custom retry logic, so this behavior must be disabled.
    @service.max_retries = 0
  end

  def get_authentication_token
    tries = 0
    begin
      tries += 1
      response = @service.head '/auth'

      # Net::HTTPResponse#value raises Net::HTTPFatalError unless the response code is 200
      # This is convenient because the error can be rescued and the block retried
      response.value

      return response['Badsec-Authentication-Token']
    rescue Net::HTTPFatalError
      retry if tries < 3
      raise API_Error.new('Server returned unsuccessful response code')
    rescue Net::OpenTimeout
      retry if tries < 3
      raise API_Error.new('Server timed out')
    rescue StandardError => e
      retry if tries < 3
      raise API_Error.new("Server error: #{e}")
    end
  end

  def get_noclist
    token = get_authentication_token
    checksum = Digest::SHA256.hexdigest("#{token}/users")
    tries = 0
    begin
      tries += 1
      response = @service.get '/users', initheader = {'X-Request-Checksum' => checksum }

      # Net::HTTPResponse#value raises Net::HTTPFatalError unless the response code is 200
      # This is convenient because the error can be rescued and the block retried
      response.value

      return response.body.split
    rescue Net::HTTPFatalError
      retry if tries < 3
      raise API_Error.new('Server returned unsuccessful response code')
    rescue Net::OpenTimeout
      retry if tries < 3
      raise API_Error.new('Server timed out')
    rescue StandardError => e
      retry if tries < 3
      raise API_Error.new("Server error: #{e}")
    end
  end
end
