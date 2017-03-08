require "slack"
require "pp"

SLACK_TARGET_DATE = Date.today - 1

Slack.configure do |config|
  config.token = ENV["SLACK_ACCESS_TOKEN"]
end

messages = Slack.client.search_all(
  query: "on:#{SLACK_TARGET_DATE.strftime("%Y-%m-%d")} in:#{ENV["SLACK_TARGET_CHANNEL"]}",
)

pp messages