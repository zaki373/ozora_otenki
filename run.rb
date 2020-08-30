require "logger"
require_relative "ozora_otenki"

#天気ツイートの時間設定
@WEATHER_TWEET_HOUR = 7
@WEATHER_TWEET_MIN  = 30

#天気APIのエリアコード設定
@AREA_CODE_IZUKA    = "izuka"
@AREA_CODE_YOKOHAMA = "yokohama"

#番組表の検索ワード設定
@SEARCH_WORD        = "アイカツ！"

#誕生日ツイートの時間設定
@BDAY_TWEET_HOUR    = 0
@BDAY_TWEET_MIN     = 0
@AKARI_BD_MONTH     = 4
@AKARI_BD_DAY       = 1

#ツイート頻度設定
@FOLLOW_BACK_PER_M  = 5
@NEWS_TWEET_PER_M   = 5

#ログ出力設定
@errlog  = Logger.new('./logs/error.log')
@infolog = Logger.new('./logs/info.log')

@errlog.formatter = proc do |severity, datetime, progname, msg|
    "[#{datetime}] #{severity} : #{msg}"
end

@infolog.formatter = proc do |severity, datetime, progname, msg|
    "[#{datetime}] #{severity} : #{msg}"
end


#ログ出力
def print_log(message)
    print "\r[#{Time.now}] #{message}".ljust(50)
end


#メイン処理
def main_process()
    @infolog.info "Bot起動\n"
    bot = OzoraOtenki.new("./data/twitter_config.yml")

    loop do 
        now = Time.now
        if now.hour == @WEATHER_TWEET_HOUR && now.min == @WEATHER_TWEET_MIN
            print_log("天気情報(飯塚)取得中")
            bot.weather_tweet_izuka(@AREA_CODE_IZUKA, now)
            print_log("天気情報(横浜)取得中")
            bot.weather_tweet_yokohama(@AREA_CODE_YOKOHAMA, now)
            print_log("番組情報取得中")
            bot.tv_tweet(@SEARCH_WORD)
        elsif now.hour == @BDAY_TWEET_HOUR && now.min == @BDAY_TWEET_MIN
            print_log("誕生日情報取得中")
            bot.birthday_tweet(now)
            if now.month == @AKARI_BD_MONTH && now.day == @AKARI_BD_DAY
                bot.birthday_tweet_for_akari() 
            end
        end
        print_log("メンション取得中")
        bot.mention_tweet()

        if now.min % @NEWS_TWEET_PER_M == 0
            print_log("ニュース取得中")
            bot.news_tweet(now)
        end

        begin
            loop do
                print_log("Bot起動中")
                sleep(1)
                break if Time.now.sec == 0
            end
        rescue Interrupt
            print "\n[#{Time.now}] Bot停止\n"
            @infolog.info "Bot停止\n"
            sleep(1)
            exit
        end
    end
end

begin
    main_process()
rescue => e
    @errlog.error "UnknownError: #{e.class}\n#{e.backtrace}\n#{e.message}\n"
    print "\n[#{Time.now}] !UnknownError: #{e}\n"
end