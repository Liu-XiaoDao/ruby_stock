#!/usr/bin/ruby
#-*- code:utf-8 -*-
require 'terminal-table'
require 'open-uri'
require 'rest-client'
require './terminal_color'

class GetStock

  def initialize()
    @base_url = "http://hq.sinajs.cn/list="
    @stock_list = "sh601298,sz000498"
    @stock_info = {}

    read_data
    get_stock_price
  end

  def get_stock_price
    row = []
    row << ["#{BColor::WHITE}代码", "名称", "昨收", "今开", "最高", "最低", "现价", "涨幅", "浮动数额", "盈亏比例", "成本金额#{BColor::ENDC}"]
    html  =  RestClient.get("#{@base_url}#{@stock_str}").body
    html = html.encode('utf-8', 'gb2312')
    lines = html.split("\n")
    lines.each do |line|
      stockInfo = line.split(',')
      temp  = stockInfo[0].split('_')[2].gsub('"','').split('=')
      code, name = temp[0], temp[1]

      todayBeginPrice   = Float(stockInfo[1])
      yersterdayEndPrice  = Float(stockInfo[2])
      currentPrice   = Float(stockInfo[3])
      todayMaxPrice = Float(stockInfo[4])
      todayMinPrice = Float(stockInfo[5])
      if '%.2f' % todayBeginPrice == '0.00'
        per = '停牌  '
      else  ('%+.2f' % ( ( currentPrice / yersterdayEndPrice - 1 ) * 100 ) )+ '%'
        per = ('%+.2f' % ( ( currentPrice / yersterdayEndPrice - 1 ) * 100 ) )+ '%'
      end
      #红涨绿跌
      todayBeginPriceColor = high_or_low(todayBeginPrice, yersterdayEndPrice)
      currentPriceColor = high_or_low(currentPrice, yersterdayEndPrice)
      todayMaxPriceColor = high_or_low(todayMaxPrice, yersterdayEndPrice)
      todayMinPriceColor = high_or_low(todayMinPrice, yersterdayEndPrice)

      stockCost = 0
      stockQuantity = 0
      floatMoney = 0
      stockRatio = 0
      floatMoneyColor = BColor::WHITE
      if @stock_info.has_key?(code) && @stock_info[code] != nil
        stockQuantity = Int(@stock_info[code][0])
        stockCost = Float(@stock_info[code][1])
        if '%.2f' % todayBeginPrice != '0.00'
          floatMoney = ( currentPrice - stockCost ) * stockQuantity
          stockRatio = ( '%+.2f' % ( (currentPrice / stockCost - 1) * 100 ) ) + '%'
          floatMoneyColor = highOrLow(currentPrice, stockCost)
        else
          floatMoney = ( yersterdayEndPrice - stockCost ) * stockQuantity
          stockRatio = ( '%+.2f' % ( (yersterdayEndPrice / stockCost - 1) * 100 ) ) + '%'
          floatMoneyColor = highOrLow(yersterdayEndPrice, stockCost)
        end
        row << ["#{BColor::WHITE}#{code}#{BColor::ENDC}","#{BColor::WHITE}#{name}#{BColor::ENDC}","#{BColor::WHITE}#{yersterdayEndPrice}#{BColor::ENDC}","#{todayBeginPriceColor}#{todayBeginPrice}#{BColor::ENDC}","#{todayMaxPriceColor}#{todayMaxPrice}#{BColor::ENDC}","#{todayBeginPriceColor}#{todayMinPrice}#{BColor::ENDC}","#{currentPriceColor}#{currentPrice}#{BColor::ENDC}","#{currentPriceColor}#{per}#{BColor::ENDC}","#{floatMoneyColor}#{floatMoney}#{stockRatio}#{BColor::ENDC}","#{BColor::WHITE}#{stockQuantity}#{BColor::ENDC}"]
      else
        row << ["#{BColor::WHITE}#{code}#{BColor::ENDC}","#{BColor::WHITE}#{name}#{BColor::ENDC}","#{BColor::WHITE}#{yersterdayEndPrice}#{BColor::ENDC}","#{todayBeginPriceColor}#{todayBeginPrice}#{BColor::ENDC}","#{todayMaxPriceColor}#{todayMaxPrice}#{BColor::ENDC}","#{todayBeginPriceColor}#{todayMinPrice}#{BColor::ENDC}","#{currentPriceColor}#{currentPrice}#{BColor::ENDC}","#{currentPriceColor}#{per}#{BColor::ENDC}","-","-","-"]
      end

    end
    puts Terminal::Table.new :rows => row
    # puts html = html.encode('utf-8', 'gb2312')
    # puts "#{BColor::RED} this is red #{BColor::ENDC}"
  end

  def high_or_low(a, b)
    a >= b ? BColor::RED : BColor::GREEN
  end

  def read_data
    raise "当前目录下没有stocks.txt文件" unless File.exist? 'stocks.txt'
    file = File.open('stocks.txt', "r")
    stock_str = file.read()
    stocks = stock_str.split("\n")
    stocks.each do |stock|
      stock_info = stock.split()
      @stock_str = "#{@stock_str}#{stock_info[0]},"
      @stock_info[stock_info[0]] = [stock_info[0], stock_info[1]] if stock_info.count == 3
    end
    @stock_str = @stock_str.chop
    file.close
  end

  def get_time
    Time.now.strftime("%Y-%m-%d %H:%M:%S %A")
  end
end

while true do
  system "clear"
  GetStock.new()
  sleep(1)
end
