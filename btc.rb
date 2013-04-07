# coding: UTF-8
require "net/http"
require "net/https"
url = URI.parse('https://btcchina.com')
http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true if url.scheme == 'https'

@price = 0.0 

while true
  http.start do |h|
    req = Net::HTTP::Get.new url.request_uri
    res = h.request req
    str = res.body.to_s
    begin_num =  str.index('Last BTC Price: </td><td align="center">')
    numstr = str[begin_num+42,12]
    numstr = numstr.delete ","
    numstr = numstr[/\d+.\d+/]
    num = numstr.to_f
    if @price - num != 0
      printf("Time:%2d/%d %02d:%02d Price: %.2f ",Time.now.month,Time.now.day,Time.now.hour,Time.now.min,num, num - @price )
      if num- @price > 0 
        printf "+"
      end
      printf("%.2f\n", num - @price)
      @price = num
    end
  end

end
