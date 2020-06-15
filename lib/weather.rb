require 'httpclient'
require 'resolv'
require 'json'
require_relative 'weather_info'

class Weather
    
    #コンストラクタ
    def initialize()
        @DESCRIPTION = "description"
        @TEXT = "text"
        @FORECASTS = "forecasts"
        @TELOP = "telop"
        @DATE = "date"
        @TEMPERATURE = "temperature"
        @CELSIUS = "celsius"
        @MIN = "min"
        @MAX = "max"
        @TODAY = 0
        @TMRW = 1
        @LOCATION = "location"
        @CITY = "city"
    end

    #メイン処理
    def do_process(area_code)
        keyword = area_code
        url = "http://weather.livedoor.com/forecast/webservice/json/v1"
        return analysis_weather(con_API(keyword, url))
    end

    #API接続
    def con_API(keyWord, url)
        client = HTTPClient.new
        query = { 'city' => keyWord }
        res = client.get(url, query)
        return JSON.parse(res.body)
    end

    #ハッシュ解析
    def analysis_weather(hash)

        info = WeatherInfo.new

        info.city = convert_nil(hash.dig(@LOCATION, @CITY))
        # 概要の取得
        info.description = convert_nil(hash.dig(@DESCRIPTION, @TEXT))

        # 本日の天気情報
        info.today_telop = convert_nil(hash.dig(@FORECASTS, @TODAY, @TELOP))
        info.today = convert_nil(hash.dig(@FORECASTS, @TODAY, @DATE))
        info.today_temp_min = convert_nil(hash.dig(@FORECASTS, @TODAY, @TEMPERATURE, @MIN, @CELSIUS))
        info.today_temp_max = convert_nil(hash.dig(@FORECASTS, @TODAY, @TEMPERATURE, @MAX, @CELSIUS))

        # 明日の天気情報
        info.tmrw_telop = convert_nil(hash.dig(@FORECASTS, @TMRW, @TELOP))
        info.tmrw = convert_nil(hash.dig(@FORECASTS, @TMRW, @DATE))
        info.tmrw_temp_min = convert_nil(hash.dig(@FORECASTS, @TMRW, @TEMPERATURE, @MIN, @CELSIUS))
        info.tmrw_temp_max = convert_nil(hash.dig(@FORECASTS, @TMRW, @TEMPERATURE, @MAX, @CELSIUS))

        return info
    end

    # nilだったら-に置き換え
    def convert_nil(value)
        return value == nil ? "－" : value
    end
end