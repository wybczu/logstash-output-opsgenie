# encoding: utf-8

require "logstash/outputs/base"
require "logstash/namespace"
require 'json'
require "uri"
require "net/http"
require "net/https"

# For more information about the api requests and their contents,
# please refer to Alert API("https://www.opsgenie.com/docs/web-api/alert-api") support doc.

class LogStash::Outputs::OpsGenie < LogStash::Outputs::Base

  config_name "opsgenie"

  # OpsGenie Logstash Integration API Key
  config :api_key, :validate => :string, :required => true

  # OpsGenie API action
  config :opsgenie_action, :validate => ["create", "close", "acknowledge", "note"], :default => "create"

  # Host of opsgenie api, normally you should not need to change this field.
  config :opsgenie_base_url, :validate => :string, :required => false, :default => 'https://api.opsgenie.com'

  # Url will be used to create alerts in OpsGenie
  config :create_action_url, :validate => :string, :required => false, :default =>'/v1/json/alert'

  # Url will be used to close alerts in OpsGenie
  config :close_action_url, :validate => :string, :required => false, :default =>'/v1/json/alert/close'

  # Url will be used to acknowledge alerts in OpsGenie
  config :acknowledge_action_url, :validate => :string, :required => false, :default =>'/v1/json/alert/acknowledge'

  # Url will be used to add notes to alerts in OpsGenie
  config :note_action_url, :validate => :string, :required => false, :default =>'/v1/json/alert/note'

  # OpsGenie alert id 
  config :alert_id, :validate => :string, :required => false

  # Alias of the alert that actions will be executed.
  config :alert_alias, :validate => :string, :required => false

  # Alert text.
  config :message, :validate => :string, :required => true

  # List of team names which will be responsible for the alert.
  config :teams, :validate => :string, :required => false

  # Detailed description of the alert.
  config :description, :validate => :string, :required => false

  # Optional user, group, schedule or escalation names to calculate which users will receive the notifications of the alert.
  config :recipients, :validate => :string, :required => false

  # Comma separated list of actions that can be executed on the alert.
  config :actions, :validate => :string, :required => false

  # Source of alert.
  config :source, :validate => :string, :required => false

  # Comma separated list of labels attached to the alert.
  config :tags, :validate => :string, :required => false

  # Set of user defined alert properties.
  config :details, :validate => :hash, :default => {"description" => "%{description}"}

  public
  def register
    opsgenie_uri = URI.parse(@opsgenie_base_url)
    @client = Net::HTTP.new(opsgenie_uri.host, opsgenie_uri.port)
    if opsgenie_uri.scheme == 'https'
      @client.use_ssl = true
      @client.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
  end # def register

  public
  def receive(event)
    alert = {
      :apiKey => @api_key
    }
    case @opsgenie_action
    when "create"
      action_path = "#{@create_action_url}"
      alert[:message] = event.sprintf(@message)
      alert[:teams] = @teams if @teams
      alert[:actions] = @actions if @actions
      alert[:description] = event.sprintf(@description) if @description
      alert[:recipients] = @recipients if @recipients
      alert[:tags] = @tags if @tags
      alert[:details] = {}
      @details.each do |key, value|
        alert[:details]["#{key}"] = event.sprintf(value)
      end
    when "close"
      action_path = "#{@close_action_url}"
    when "acknowledge"
      action_path = "#{@acknowledge_action_url}"
    when "note"
      action_path = "#{@note_action_url}"
    else
      @logger.warn("Action #{opsgenie_action} does not match any available action, discarding..")
      return
    end

    alert['alias'] = event.sprintf(@alert_alias) if @alert_alias
    alert['id'] = event.sprintf(@alert_id) if @alert_id

    begin
      request = Net::HTTP::Post.new(action_path)
      request.body = LogStash::Json.dump(alert)
      @logger.debug("OpsGenie Request", :request => request.inspect)
      response = @client.request(request)
      @logger.debug("OpsGenie Response", :response => response.body)
    rescue Exception => e
      @logger.error("OpsGenie Unhandled exception", :pd_error => e.backtrace)
    end
  end # def receive
end # class LogStash::Outputs::OpsGenie
