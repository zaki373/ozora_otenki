require_relative "weather"
require_relative "weather_info"

class Mention
    def initialize()
    end

    #ワードの配列セット
    def uttr_set()
        uttr_list = []
        file = "./data/AikatsuWord.txt"
        IO.foreach(File.expand_path(file), :mode => "r:utf-8") do |line|
            line.chomp!
            next if line[0,1] == '#'|| line.length == 0
            unit = line.split(' ')
            data = {}
            data[:word]   = unit[0]
            data[:return] = unit[1]
            uttr_list << data
        end
        return uttr_list
    end

    def do_reply(text)
        if text =~ /(明日|あした).*(天気|てんき)/
            weather_obj = Weather.new
            info = weather_obj.do_process(400030)
            reply =  "明日の飯塚市のお天気は【#{info.tmrwTelop}】\n"
            reply += "最低気温は【#{info.tmrwTempMin}℃】\n最高気温は【#{info.tmrwTempMax}℃】です❗"
            return reply
        end
    
        uttr_list = uttr_set()
        uttr_list.each do |uttr_data|
            if text =~ /#{uttr_data[:word]}/
                return uttr_data[:return]
            end
        end
    
        reply_list = []
        file = "./data/reply.txt"
        File.open(File.expand_path(file),"r:utf-8") do |file|
            file.each_line do |line|
                line.chomp!
                reply_list << "#{line}"
            end
        end
        return reply_list[rand(reply_list.size)]
    end
end