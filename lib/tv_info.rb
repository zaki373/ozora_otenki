require 'nokogiri'
require 'open-uri'
require 'chronic'
require 'optparse'

class TVInfo
    def initilize()
    end

    #yahoo番組表から検索ワードの番組一覧（1週間分）を取得
    #ハッシュが入った配列として返す
    def get_week_list(search_word)
        url = URI.encode 'https://tv.yahoo.co.jp/search/?q='+search_word+'&a=23&oa=1'
    
        charset = nil
    
        html = open(url) do |f|
            charset = f.charset
            f.read
        end
    
        tv_hash_list = []
    
        doc = Nokogiri::HTML.parse(html, nil, charset)
        doc.xpath('//ul[@class="programlist"]').each do |node|
            node.xpath(".//li").each do |node1|
                tv_hash = {}
                node1.xpath(".//div[@class='leftarea']").each do |node2|
                    time = node2.xpath(".//p")
                    youbi = /（(月|火|水|木|金|土|日)）/
                    tv_hash[:time] = Chronic.parse(time.text.sub(youbi,' ').sub(/～(.+):(.+)/,''))
                end
    
                title = node1.xpath(".//p[@class='yjLS pb5p']")
                tv_hash[:title] = title.text
    
                station = node1.xpath(".//p[@class='yjMS pb5p']").xpath(".//span[@class='pr35']")
                tv_hash[:station] = station.text
    
                tv_hash_list << tv_hash
            end
        end
        return tv_hash_list
    end

    #取得した番組の中で今日放送のものだけを返す
    def get_today_list(search_word)
        today_list = []
        get_week_list(search_word).each do |info|
            if info[:time].day == Time.now.day
                today_list << info
            end
        end
        return today_list
    end
end

=begin
@option={}
OptionParser.new do |opt|
  opt.on('-q [VALUE]','番組検索を行う（指定なしは「アイカツ」）'){|v| @option[:q] = v}
  opt.on('-p','結果を出力する') {|v| @option[:p] = v}
  opt.on('-a','一週間分リスト表示') {|v| @option[:a] = v}
  
  opt.parse!(ARGV)
end

if @option[:p]
    tweet = make_tvtweet()
    if tweet
        print tweet
    else
        puts "今日は番組がありません"
    end
end
=end