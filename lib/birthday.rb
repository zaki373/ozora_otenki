class Birthday
    def initialize()
    end

    #誕生日のキャラの名前と画像パスを返す
    def get_today_list(now)
        today_birthday_list = []
        file = "./data/birthday.txt"
        IO.foreach(File.expand_path(file), :mode => "r:utf-8") do |line|
            line.chomp!
            next if line[0,1] == '#' || line.length == 0
            unit = line.split(' ')
            if now.month == unit[0].to_i && now.day == unit[1].to_i
                data = {}
                data[:name]  = unit[2]
                data[:image] = unit[3]
                today_birthday_list << data
            end
        end
        return today_birthday_list
    end
end
