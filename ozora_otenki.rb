require "twitter"
require "yaml"
require "logger"
require_relative "lib/tv_info"
require_relative "lib/birthday"
require_relative "lib/news"
require_relative "lib/mention"
require_relative "lib/weather"
require_relative "lib/weather_info"

class OzoraOtenki

    #コンストラクタ
    def initialize(config_file)
        #TwitterAPIのキー設定
        @client = Twitter::REST::Client.new do |config|
            config.consumer_key        = YAML.load_file(config_file)["consumer_key"]
            config.consumer_secret     = YAML.load_file(config_file)["consumer_secret"]
            config.access_token        = YAML.load_file(config_file)["access_token"]
            config.access_token_secret = YAML.load_file(config_file)["access_token_secret"]
        end

        #ログ出力設定
        @errlog  = Logger.new('./logs/error.log')
        @infolog = Logger.new('./logs/info.log')

        @errlog.formatter = proc do |severity, datetime, progname, msg|
            "[#{datetime}] #{severity} : #{msg}"
        end

        @infolog.formatter = proc do |severity, datetime, progname, msg|
            "[#{datetime}] #{severity} : #{msg}"
        end
    end

    #情報ログ出力
    def print_info(message)
        @infolog.info("#{message}\n")
        print "\n[#{Time.now}] #{message}\n"
    end

    #エラーログ出力
    def print_err(e, message)
        @errlog.error("#{message}: #{e.class}\n#{e.backtrace}\n#{e.message}\n")
        print "\n[#{Time.now}] !#{message}: #{e}\n"
    end


    #天気ツイート（飯塚）
    def weather_tweet_izuka(area_code_izuka, now)
        weather_obj = Weather.new
        begin 
            info = weather_obj.do_process(area_code_izuka)

            tweet =  "みなさん、おはようございます❗\n"
            tweet += "時刻は#{now.hour}時#{now.min}分\n今日のお空はどんな空～❓\n"
            tweet += "大空お天気の時間です❗\n今日の#{info.city}市のお天気は【#{info.today_telop}】\n"
            tweet += "最高気温は【#{info.today_temp_max}℃】です❗"

            images = []
            images << File.new("./images/お天気.jpg")
            @client.update_with_media(tweet, images)

            print_info("天気: #{info.city},#{info.today_telop},#{info.today_temp_max}")
        rescue => e
            print_err(e, "WeatherError")
        end
    end


    #天気ツイート（横浜）
    def weather_tweet_yokohama(area_code_yokohama, now)
        weather_obj = Weather.new
        begin 
            info = weather_obj.do_process(area_code_yokohama)

            tweet =  "続いて#{info.city}市のお天気です❗\n"
            tweet += "今日の#{info.city}市のお天気は【#{info.today_telop}】\n"
            tweet += "最高気温は【#{info.today_temp_max}℃】です❗\n"
            tweet += "それでは皆さん、通勤・通学気をつけて❗\nいってらっしゃい👋"

            images = []
            images << File.new("./images/通勤通学.jpg")
            @client.update_with_media(tweet, images)

            print_info("天気: #{info.city},#{info.today_telop},#{info.today_temp_max}")
        rescue => e
            print_err(e, "WeatherError")
        end
    end


    #放送日ツイート
    def tv_tweet(search_word)
        tv_info = TVInfo.new
        begin
            today_tv_list = tv_info.get_today_list(search_word)

            tweet = "今日は『" + search_word + "』の放送日❗"
            today_tv_list.each do |tv|
                tweet += "\n#{tv[:time].strftime("%H時%M分")}から #{tv[:station]}で\n#{tv[:title]}"
            end

            if !today_tv_list.empty?
                tweet += " が放送です❗\nぜひ見てくださいね❗"
                
                images = []
                images << File.new("./images/アイドル活動.png")
                @client.update_with_media(tweet, images)

                print_info("放送日: #{tweet.gsub("\n", " ")}")
            end
        rescue => e
            print_err(e, "TVError")
        end
    end


    #誕生日ツイート
    def birthday_tweet(now)
        birthday = Birthday.new
        begin
            today_birthday_list = birthday.get_today_list(now)

            if !today_birthday_list.empty?
                images = []
                tweet = "本日、#{now.month}月#{now.day}日は"
                today_birthday_list.each_with_index do |birthday, index|
                    if index == 0
                        tweet += "#{birthday[:name]}"
                    else
                        tweet += "と#{birthday[:name]}"
                    end
                    images << File.new(birthday[:image])

                    print_info("誕生日: #{birthday[:name]}")
                end
                tweet += "のお誕生日です❗\n"
                tweet += "お誕生日おめでとうございます❗🍰"
            
                @client.update_with_media(tweet, images)
            end
        rescue => e
            print_err(e, "BirthdayError")
        end
    end


    #大空あかりさんの誕生日ツイート
    def birthday_tweet_for_akari()
        tweet =  "こんばんは❗星宮いちごです❗🍓\n"
        tweet += "今日はあかりちゃんに代わってお誕生日のお知らせをします❗\n"
        tweet += "今日、4月1日は大空あかりちゃんのお誕生日❗\n"
        tweet += "誕生日おめでとう❗あかりちゃん❗"
        
        images = []
        images << File.new("./images/birthday/akari.png")

        begin
            @client.update_with_media(tweet, images)
            print_info("誕生日: 大空あかり")
        rescue => e
            print_err(e, "BirthdayError")
        end 
    end


    #ニュースツイート
    def news_tweet(now)
        news = News.new
        begin
            news_list = news.get_list(now)

            if !news_list.empty?
                print "\n"
                tweet_list = []
                url_size   = 12
                tweet_size = 10
                tweet = "新しいお知らせです❗\n"
                
                news_list.each do |news|
                    tweet_size += news["title"].size + url_size
                    if tweet_size > 130
                        tweet_list << tweet
                        tweet =  "さらにお知らせです❗\n"
                        tweet += "\n☆#{news["title"]}\n#{news["url"]}\n"
                        tweet_size = 10 + news["title"].size + url_size
                    else
                        tweet += "\n☆#{news["title"]}\n#{news["url"]}\n"
                    end

                    print_info("ニュース: #{news["title"]}")
                end
                tweet_list << tweet

                tweet_list.each do |tweet|
                    @client.update(tweet)
                    sleep(5)
                end
            end
        rescue => e
            print_err(e, "NewsError")
        end
    end


    #メンション
    def mention_tweet()
        mention = Mention.new
        update_id = -1
        begin
            File.open("./data/mention","r") do |file|
                @client.mentions_timeline(options = {:since_id => file.read.to_i}).each do |tweet|
                    reply = mention.do_reply(tweet.text)
                    @client.update("@#{tweet.user.screen_name}\n#{reply}", options = {:in_reply_to_status_id => tweet.id})
                    @client.favorite(tweet.id)
                    update_id = tweet.id if tweet.id > update_id

                    print_info("返信: #{msg} => @#{tweet.user.screen_name} #{tweet.text.gsub("\n", " ")}")
                end

                if update_id != -1
                    File.open("./data/mention","w") do |f|
                        f.puts(update_id)
                    end
                end
            end
        rescue => e
            print_err(e, "MentionError")
        end
    end


    #フォロバ
    def follow_back()
        follower_ids = []
        friend_ids = []

        begin
            @client.follower_ids.each do |id|
                follower_ids.push(id)
            end

            @client.friend_ids.each do |id|
                friend_ids.push(id)
            end
        
            flist = follower_ids - friend_ids
        
            if !flist.empty?
                @client.follow(flist)
                print_info("フォローバック: #{flist}")
            end
        rescue => e
            print_err(e, "FollowBackError")
        end
    end

end