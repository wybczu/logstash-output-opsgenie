require "logstash/devutils/rspec/spec_helper"
require "logstash/outputs/opsgenie"
require "logstash/codecs/plain"
require "logstash/event"

describe LogStash::Outputs::OpsGenie do

  subject {LogStash::Outputs::OpsGenie.new( "api_key" => "my_api_key" )}
  let(:logger) { subject.logger}

end
