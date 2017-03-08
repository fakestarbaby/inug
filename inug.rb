require "slack"
require "pp"

SLACK_TARGET_DATE = Date.today - 1

Slack.configure do |config|
  config.token = ENV["SLACK_ACCESS_TOKEN"]
end

messages = Slack.client.search_all(
  query: "on:#{SLACK_TARGET_DATE.strftime("%Y-%m-%d")} in:#{ENV["SLACK_TARGET_CHANNEL"]}",
)

channels = Slack.client.channels_list()["channels"]
target_channel = channels.select {|channel| channel["name"] == ENV["SLACK_TARGET_CHANNEL"] }.first

messages["messages"]["matches"].each do |message|
  reactions = Slack.client.reactions_get(channel: target_channel["id"], timestamp: message["ts"])
  next if reactions["message"]["reactions"].nil?

  if (reactions["message"]["reactions"].select {|reaction| reaction["name"] == ENV["SLACK_NIPPO_EMOJI_REACTION"]}.size != 0)
    pp message["text"]
    break
  end
end
