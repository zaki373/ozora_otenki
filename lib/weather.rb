require 'open-uri'
require 'net/http'
require "nokogiri"
require_relative 'weather_info'

class Weather
    
    #コンストラクタ
    def initialize()
    end

    #メイン処理
    def do_process(area_code)
        info = WeatherInfo.new

        info.today = Time.now.strftime("%Y/%m/%d")
        info.tmrw  = (Time.now + 86400).strftime("%Y/%m/%d")

        if (area_code == "izuka")
            url = "https://www.drk7.jp/weather/xml/40.xml"
            xml = Nokogiri::XML(open(url).read)
            
            today_path = xml.xpath('//area[@id="筑豊地方"]').xpath("./info[@date='#{info.today}']")
            tmrw_path  = xml.xpath('//area[@id="筑豊地方"]').xpath("./info[@date='#{info.tmrw}']")

        elsif (area_code == "yokohama")
            url = "https://www.drk7.jp/weather/xml/14.xml"
            xml = Nokogiri::XML(open(url).read)
            
            today_path = xml.xpath('//area[@id="東部"]').xpath("./info[@date='#{info.today}']")
            tmrw_path  = xml.xpath('//area[@id="東部"]').xpath("./info[@date='#{info.tmrw}']")

        end

        info.today_telop = today_path.xpath('./weather').text
        info.today_temp_max = today_path.xpath('./temperature[@unit="摂氏"]').xpath('./range[@centigrade="max"]').text
        info.today_temp_min = today_path.xpath('./temperature[@unit="摂氏"]').xpath('./range[@centigrade="min"]').text

        info.tmrw_telop = tmrw_path.xpath('./weather').text
        info.tmrw_temp_max = tmrw_path.xpath('./temperature[@unit="摂氏"]').xpath('./range[@centigrade="max"]').text
        info.tmrw_temp_min = tmrw_path.xpath('./temperature[@unit="摂氏"]').xpath('./range[@centigrade="min"]').text

        return info
    end
end