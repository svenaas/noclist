require_relative '../noclist.rb'
require 'json'

RSpec::Matchers.define_negated_matcher :not_output, :output

RSpec.describe Noclist, "::print_noclist" do
  context "when the server behaves" do
    it "prints the noclist to stdout" do
      stub_request(:head, 'http://localhost:8888/auth').
        to_return(status: 200, body: "", headers: { 'Badsec-Authentication-Token' => "12345"})
      stub_request(:get, 'http://localhost:8888/users').
        to_return(status: 200, body: "1\n2\n3\n4\n5\n")

      expect{ Noclist.print_noclist }.to output(['1','2','3','4','5'].to_json + "\n").to_stdout
    end

    it "outputs nothing to stderr" do
      stub_request(:head, 'http://localhost:8888/auth').
        to_return(status: 200, body: "", headers: { 'Badsec-Authentication-Token' => "12345"})
      stub_request(:get, 'http://localhost:8888/users').
        to_return(status: 200, body: "1\n2\n3\n4\n5\n")

       # Both outputs tested here in order to prevent the stdout output from appearing when rspec is run
      expect{ Noclist.print_noclist }.to output.to_stdout.and not_output.to_stderr
    end
  end

  context "when the server misbehaves" do
    it "prints an error to stderr" do
      stub_request(:head, 'http://localhost:8888/auth').
        to_timeout
      expect{ Noclist.print_noclist }.to output("Server timed out\n").to_stderr
    end

    it "prints nothing to stdout" do
      stub_request(:head, 'http://localhost:8888/auth').
        to_timeout

      # Both outputs tested here in order to prevent the stderr output from appearing when rspec is run
      expect{ Noclist.print_noclist }.to output.to_stderr.and not_output.to_stdout
    end
  end
end
