class WeatherInfo
    attr_accessor :city,
    :description,
    :today_telop,
    :today,
    :today_temp_min,
    :today_temp_max,
    :tmrw_telop,
    :tmrw,
    :tmrw_temp_min,
    :tmrw_temp_max,
    :comment

    #コンストラクタ
    def initialize()
        @city = ""
        @description = ""
        @today_telop = ""
        @today = ""
        @today_temp_min = ""
        @today_temp_max = ""
        @tmrw_telop = ""
        @tmrw = ""
        @tmrw_temp_min = ""
        @tmrw_temp_max = "" 
        @comment = ""
    end
  
end