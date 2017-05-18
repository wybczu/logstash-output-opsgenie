# OpsGenie Logstash No Mutate Plugin

This is a plugin for [Logstash](https://github.com/elastic/logstash). It's
base on OpsGenie original plugin. The only difference is that you do not have
to modify your events to add OpsGenie specific fields to them.

### Install and Run OpsGenie Output Plugin in Logstash

OpsGenie Logstash Output plugin is available in
[RubyGems.org](https://rubygems.org/gems/logstash-output-opsgenienm)

- Install plugin
```sh
bin/plugin install logstash-output-opsgenienm
```

- OpsGenie has Logstash Integration. To use the plugin you need to add a
  [Logstash Integration](https://app.opsgenie.com/integration?add=Logstash) in
  OpsGenie and obtain the API Key.
- Add the following configuration to your configuration file

```sh
output {
	opsgenie {
		"api_key" => "logstash_integration_api_key"
	}
}
```
