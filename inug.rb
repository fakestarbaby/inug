require "slack"
require "esa"
require "pp"

SLACK_TARGET_DATE = Date.today - 1
PLACEHOLDER_ESA_SCREEN_NAME = "%{me}"
PLACEHOLDER_ESA_TITLE = "%{title}"

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
    esa_client = Esa::Client.new(access_token: ENV["ESA_ACCESS_TOKEN"], current_team: ENV["ESA_CURRENT_TEAM"])

    body_md = message["text"]
    name = ENV["ESA_NIPPO_TITLE"].gsub(/#{PLACEHOLDER_ESA_TITLE}/, body_md.lines.first.chomp)
    if name.include?(PLACEHOLDER_ESA_SCREEN_NAME)
      screen_name = esa_client.user.body["screen_name"]
      name.gsub!(/#{PLACEHOLDER_ESA_SCREEN_NAME}/, screen_name)
    end

    esa_client.create_post(
      category: "#{ENV["ESA_NIPPO_CATEGORY"]}/#{SLACK_TARGET_DATE.strftime("%Y/%m/%d")}",
      name: name,
      body_md: body_md,
    )

    break
  end
end
