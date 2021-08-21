require_relative '../lib/badsec.rb'
require 'digest'

RSpec.describe BADSEC_API_Client do 
	let(:badsec) { BADSEC_API_Client.new }

	describe '#get_authentication_token' do
		context "when the server behaves" do
			it "gets an authentication token" do
				stub_request(:head, 'http://localhost:8888/auth').
					to_return(status: 200, body: "", headers: { 'Badsec-Authentication-Token' => "12345"})			
				expect(badsec.get_authentication_token).to eq "12345"
			end
		end

		context "when the server consistently times out" do
			it "raises an error" do
				stub_request(:head, 'http://localhost:8888/auth').
					to_timeout
				expect{badsec.get_authentication_token}.to raise_error(API_Error, "Server timed out")
			end
		end

		context "when the server times out twice and then succeeds" do
			it "gets an authentication token" do
				stub_request(:head, 'http://localhost:8888/auth').
					to_timeout.times(2).then.
					to_return(status: 200, body: "", headers: { 'Badsec-Authentication-Token' => "12345"})
				expect(badsec.get_authentication_token).to eq "12345"
			end
		end

		context "when the server consistently fails to return a 200 response code" do
			it "raises an error" do
				stub_request(:head, 'http://localhost:8888/auth').
					to_return(status: 500)
				expect{badsec.get_authentication_token}.to raise_error(API_Error, "Server returned unsuccessful response code")
			end
		end

		context "when the server twice fails to return a 200 response code and then succeeds" do
			it "raises an error" do
				stub_request(:head, 'http://localhost:8888/auth').
					to_return(status: 500).times(2).then.
					to_return(status: 200, body: "", headers: { 'Badsec-Authentication-Token' => "12345"})
				expect(badsec.get_authentication_token).to eq "12345"
			end
		end		

		context "when the server consistently raises unexpected errors" do
			it "raises an error" do
				stub_request(:head, 'http://localhost:8888/auth').
					to_raise("Balky server error")
				expect{badsec.get_authentication_token}.to raise_error(API_Error, "Server error: Balky server error")
			end
		end

		context "when the server raises unexpected errors twice and then succeeds" do
			it "gets an authentication token" do
				stub_request(:head, 'http://localhost:8888/auth').
					to_raise("Balky server error").times(2).then.
					to_return(status: 200, body: "", headers: { 'Badsec-Authentication-Token' => "12345"})
				expect(badsec.get_authentication_token).to eq "12345"
			end
		end
	end

	describe '#get_noclist' do
		context "when authentication is successful" do 
			before do
				stub_request(:head, 'http://localhost:8888/auth').
					to_return(status: 200, body: "", headers: { 'Badsec-Authentication-Token' => "12345"})
			end

			# TODO: Find a better way to assert well-formedness of checksum
			it "includes a valid checksum in an API call" do
				stub_request(:get, 'http://localhost:8888/users').
			 		with(headers: {"X-Request-Checksum" => Digest::SHA256.hexdigest('12345/users')}).
			 		to_return(status: 200)
			 	expect{badsec.get_noclist}.not_to raise_error
			end

			context "and then the server continues to behave" do
				it "gets a valid noclist" do
					stub_request(:get, 'http://localhost:8888/users').
						to_return(status: 200, body: "1\n2\n3\n4\n5\n")	
					expect(badsec.get_noclist).to eq ['1','2','3','4','5']
				end
			end

			context "and then the server consistently times out" do
				it "raises an error" do
					stub_request(:get, 'http://localhost:8888/users').
						to_timeout
					expect{badsec.get_noclist}.to raise_error(API_Error, "Server timed out")
				end
			end

			context "and then the server times out twice and then succeeds" do
				it "gets an authentication token" do
					stub_request(:get, 'http://localhost:8888/users').
						to_timeout.times(2).then.
						to_return(status: 200, body: "1\n2\n3\n4\n5\n")	
					expect(badsec.get_noclist).to eq ['1','2','3','4','5']
				end
			end

			context "and then the server consistently fails to return a 200 response code" do
				it "raises an error" do
					stub_request(:get, 'http://localhost:8888/users').
						to_return(status: 500)
					expect{badsec.get_noclist}.to raise_error(API_Error, "Server returned unsuccessful response code")
				end
			end

			context "and then the server twice fails to return a 200 response code and then succeeds" do
				it "raises an error" do
					stub_request(:get, 'http://localhost:8888/users').
						to_return(status: 500).times(2).then.
						to_return(status: 200, body: "1\n2\n3\n4\n5\n")	
					expect(badsec.get_noclist).to eq ['1','2','3','4','5']
				end
			end		

			context "and then the server consistently raises unexpected errors" do
				it "raises an error" do
					stub_request(:get, 'http://localhost:8888/users').
						to_raise("Balky server error")
					expect{badsec.get_noclist}.to raise_error(API_Error, "Server error: Balky server error")
				end
			end

			context "and then the server raises unexpected errors twice and then succeeds" do
				it "gets an authentication token" do
					stub_request(:get, 'http://localhost:8888/users').
						to_raise("Balky server error").times(2).then.
						to_return(status: 200, body: "1\n2\n3\n4\n5\n")	
					expect(badsec.get_noclist).to eq ['1','2','3','4','5']
				end
			end			
		end
	end
end