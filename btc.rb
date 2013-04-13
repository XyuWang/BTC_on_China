# coding: UTF-8
require "net/http"
require "net/https"
require 'colorize'
require 'ruby-debug'
class Btc
  def initialize
    @last_price = 0.0
    @lowest_price = 10000000.0
    @highest_price = 0.0
    @url = URI.parse('https://btcchina.com')
    @net = Net::HTTP.new(@url.host, @url.port)
    @net.use_ssl = true if @url.scheme == 'https'
  end
  def run
    while true
      @net.start do |http|
        next unless get_price_from_respond 
        print_line get_line
        @last_price = @price
      end
    end
  end

  private
  def get_price_from_respond 
    respond = @net.request(Net::HTTP::Get.new(@url.request_uri))
    price_string_index = respond.body.to_s.index('Last BTC Price: </td><td align="center">') + 42
    return nil if price_string_index == nil
    price_string = respond.body.to_s[price_string_index,12]
    price_string = price_string.delete ","
    numstr = price_string[/\d+.\d+/]
    @price = numstr.to_f
    @highest_price = @price  if @price > @highest_price
    @lowest_price  = @price  if @price < @lowest_price
    return true
  end
  def get_line
    if @price - @last_price != 0
      line = ""
      line += sprintf("Time:%2d/%d %02d:%02d Price: %.2f ",Time.now.month,Time.now.day,Time.now.hour,Time.now.min,@price, @price - @last_price )
      if @price - @last_price > 0 
        line += '+' 
      end
      line += sprintf("%.2f", @price - @last_price)
      return line
    else
      return nil
    end
  end
  def print_line line
    return if line == nil or @price == @last_price
    if @price == @highest_price
      puts line.red
    elsif @price == @lowest_price
      puts line.white
    elsif @price > @last_price
      puts line.green
    else
      puts line.yellow
    end
  end

end

Btc.new.run
