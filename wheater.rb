# frozen_string_literal: true

require 'faraday'

# Wheter class get informartions about the wheater of the world
class Wheater
  BASE_URL = 'http://api.weatherapi.com/v1'

  def initialize(api_key: nil)
    @api_key = api_key
  end

  def self.locations
    locations = JSON.parse(File.read('./cities.json'))
    locations['cities'].map do |city|
      {
        id: city['codigo_ibge'],
        city: city['nome'],
        lat: city['latitude'],
        long: city['longitude']
      }
    end
  end

  def current_wheater(location)
    current_url = "#{BASE_URL}/current.json?key=#{@api_key}&q=#{location}&aqi=no"
    response = Faraday.get current_url
    return { errors: JSON.parse(response.body)[:error], status: response.status } unless response.status == 200

    result = JSON.parse(response.body)

    <<-MESSAGE
      Localidade: <strong>#{result['location']['name']}/#{result['location']['region']}</strong>
      Temperatura: <strong>#{result['current']['temp_c']} graus</strong>
    MESSAGE
  end
end
