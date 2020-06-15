require 'json'
require 'nokogiri'
require 'open-uri'
require 'chronic'

class News
    def initialize()
        @file = "./data/news.json"
    end

    def set_old_news()
        old_news = []

        File.open(File.expand_path(@file), 'r') do |f|
            s = f.read
            if s != ''
                old_news = JSON.parse(s)
            end
        end

        return old_news
    end

    def get_list(now)
        url = URI.encode 'https://www.aikatsu.com/onparade/'

        charset = nil
        html = open(url) do |f|
            charset = f.charset
            f.read
        end

        old_news = set_old_news()
        news_hash_list = []

        doc = Nokogiri::HTML.parse(html, nil, charset)
        doc.xpath('//div[@class="topicsCol_box"]').each do |node|
            node.xpath(".//a").each do |node1|
                news_hash = {}
                node1.at(:span).remove       
                news_hash["date"] = node1.css('dt').text
                t = Chronic.parse(news_hash["date"])
                if t.day == now.day && t.month == now.month
                    news_hash["title"] = node1.css('dd').text
                    news_hash["url"] = node1.attribute('href').text
                    unless news_hash["title"] =~ /ランキング/
                        news_hash_list << news_hash
                    end
                end
            end           
        end

        File.open(File.expand_path(@file), 'w') do |f|
            str = JSON.dump(news_hash_list, f)
        end

        return news_hash_list - old_news
    end
end