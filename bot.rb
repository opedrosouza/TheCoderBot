# frozen_string_literal: true

require 'dotenv/load'
require 'telegram/bot'
require './wheater'

token = ENV['TELEGRAM_API_KEY']
@wheater = Wheater.new(api_key: ENV['WHEATER_API_KEY'])

def inline_query_results(_, count)
  Wheater.locations.first(count).map do |result|
    [
      result[:id].to_s,
      "Clima em #{result[:city]}",
      @wheater.current_wheater("#{result[:lat]},#{result[:long]}")
    ]
  end
end

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    case message
    when Telegram::Bot::Types::InlineQuery
      results = inline_query_results(0, 10).map do |arr|
        Telegram::Bot::Types::InlineQueryResultArticle.new(
          id: arr[0],
          title: arr[1],
          input_message_content: Telegram::Bot::Types::InputTextMessageContent.new(message_text: arr[2], parse_mode: 'HTML')
        )
      end

      bot.api.answer_inline_query(inline_query_id: message.id, results: results)
    when Telegram::Bot::Types::Message
      case message.text
      when '/start'
        bot.api.send_message(chat_id: message.chat.id, text: "Hello, #{message.from.first_name}")
      when '/stop'
        bot.api.send_message(chat_id: message.chat.id, text: "Bye, #{message.from.first_name}")
      end
      if message.text.include?('clima')
        location = message.text.split('clima').last
        response = @wheater.current_wheater(location)
        bot.api.send_message(chat_id: message.chat.id, text: response, parse_mode: 'HTML')
      end
    end
  end
end
