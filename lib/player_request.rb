require 'yaml'

class PlayerRequest
  @@web_session_cookie = 'A3sq38EiPRy9x4eUUGJ1i3w1gheDSetU9gPpYDfBPGKO0fl1C4XFl4LKJ3eI4X8huzJZoYN7I3dEKd0x17RiCdGC3XWvgJ7%2FT%2F7OFlX6Z9sMWuWI64H2kmZlReUAycRehQXKYOg%2B%2BotTTDpE0KreywSaVoea1bMuFhJDdsNlZYJGyidUXeKXwHQxYWasU2VfT44RPI1m3gYdaxor4szySm3uJmc6SztgWMTZXOSpB4EjY3LUCidfaEKFs3hQcnTtGx5wItE1TbXirWQqWuh0eDf%2FiTYm%2BmS7LtFdi%2BUaKZMFH25B%2BB%2Ffgck0u6e8PCI5UgK%2FUoHUbQQms3vhEW%2BHfXLyXpYFBARSrOTFGAGiBOchm01P4Y%2FuGTMDhQqJ9iJLRmFrmacZ4m%2BgcRAXhXqZNoAxp9Mq6tPWr4ja9%2BCtCPkiwbGeojIysshsdlWXFUhIewNDqV2bbEpaLMYb7VYHgXT%2FAO5fnuhVrxSPS0jPcgfeUabHobk3BOyAKpyDv1AAKD%2F7LAeBGcaimW1a3GHgEjVi9XgfRVa5x4J9lcGqmCEhJXoD7lwtdXEE3x%2BaC7sfXFID7zySm1bIwsgK7w%3D%3D--TReyKiFdRVCgkOsR--9kXntgXTdpl16usfgrJhLQ%3D%3D'
  @@last_url_cookie = 'KnaZ8uAmdzV9Gbvrf3jsBxgaGzD1eofc%2FasR%2B9b56LjbEbCbCPJ3vIUTov8R%0AV87d%0A'
  @@etag = '195b065e98c37ebe565e63ae0798f396'

  def self.web_session_cookie
    @@web_session_cookie
  end

  def self.last_url_cookie
    @@last_url_cookie
  end

  def self.etag
    @@etag
  end

  def self.get(id)
    uri = URI.parse("https://mlb19.theshownation.com/community_market/listings/#{id}")
    # request = Net::HTTP::Get.new(uri)
    # request["Authority"] = "mlb19.theshownation.com"
    # request["Cache-Control"] = "max-age=0"
    # request["Upgrade-Insecure-Requests"] = "1"
    # request["User-Agent"] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.157 Safari/537.36"
    # request["Accept"] = "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3"
    # request["Referer"] = "https://mlb19.theshownation.com/community_market"
    # request["Accept-Language"] = "en-US,en;q=0.9"
    # request["Cookie"] = "mlb19_last_url=#{@@last_url_cookie}; _mlb19_web_session=#{@@web_session_cookie}"
    # request["If-None-Match"] = "W/\"#{@@etag}\""

    # req_options = {
    #   use_ssl: uri.scheme == "https",
    # }

    # response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
    #   http.request(request)
    # end

    # @@etag = response.header['etag']
    # update_cookie_values(response)
    # response


    request = Net::HTTP::Get.new(uri)
    request["Authority"] = "mlb19.theshownation.com"
    request["Cache-Control"] = "max-age=0"
    request["Upgrade-Insecure-Requests"] = "1"
    request["User-Agent"] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.169 Safari/537.36"
    request["Accept"] = "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3"
    request["Accept-Language"] = "en-US,en;q=0.9"
    request["Cookie"] = "mlb19_last_url=#{@@last_url_cookie}; _mlb19_web_session=#{@@web_session_cookie}"
    request["If-None-Match"] = "W/\"195b065e98c37ebe565e63ae0798f396\""

    req_options = {
      use_ssl: uri.scheme == "https",
    }

    
    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
    update_cookie_values(response)
    response
  end

  def self.create_buy_order(player_id, token, price)
    uri = URI.parse("https://mlb19.theshownation.com/community_market/listings/#{player_id}/create_buy_order")
    request = Net::HTTP::Post.new(uri)
    request.content_type = "application/x-www-form-urlencoded"
    request["Authority"] = "mlb19.theshownation.com"
    request["Cache-Control"] = "max-age=0"
    request["Origin"] = "https://mlb19.theshownation.com"
    request["Upgrade-Insecure-Requests"] = "1"
    request["User-Agent"] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.157 Safari/537.36"
    request["Accept"] = "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3"
    request["Referer"] = "https://mlb19.theshownation.com/community_market/listings/a202f9321eb302847309bb57bec072d5"
    request["Accept-Language"] = "en-US,en;q=0.9"
    request["Cookie"] = "mlb19_last_url=#{@@last_url_cookie}; _mlb19_web_session=#{@@web_session_cookie}"
    request.set_form_data(
      "authenticity_token" => "#{token}",
      "button" => "",
      "price" => "#{price}",
      "utf8" => "✓",
    )

    req_options = {
      use_ssl: uri.scheme == "https",
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
    binding.pry
    # update_cookie_values(response)
    response
  end

  def self.create_sell_order(player_id, token, price)
    uri = URI.parse("https://mlb19.theshownation.com/community_market/listings/#{player_id}/create_sell_order")
    request = Net::HTTP::Post.new(uri)
    request.content_type = "application/x-www-form-urlencoded"
    request["Authority"] = "mlb19.theshownation.com"
    request["Cache-Control"] = "max-age=0"
    request["Origin"] = "https://mlb19.theshownation.com"
    request["Upgrade-Insecure-Requests"] = "1"
    request["User-Agent"] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.157 Safari/537.36"
    request["Accept"] = "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3"
    request["Referer"] = "https://mlb19.theshownation.com/community_market/listings/637f65551fcad36c70e072ceb31799ba"
    request["Accept-Language"] = "en-US,en;q=0.9"
    request["Cookie"] = "mlb19_last_url=#{@@last_url_cookie}; _mlb19_web_session=#{@@web_session_cookie}"
    request.set_form_data(
      "authenticity_token" => "#{token}",
      "button" => "",
      "price" => "#{price}",
      "utf8" => "✓",
    )

    req_options = {
      use_ssl: uri.scheme == "https",
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    # update_cookie_values(response)
    response
  end

  def self.cancel_order(order_id, player_id, token)
    uri = URI.parse("https://mlb19.theshownation.com/community_market/orders/#{player_id}/cancel_from_listing?order_id=#{order_id}")
    request = Net::HTTP::Post.new(uri)
    request.content_type = "application/x-www-form-urlencoded"
    request["Authority"] = "mlb19.theshownation.com"
    request["Cache-Control"] = "max-age=0"
    request["Origin"] = "https://mlb19.theshownation.com"
    request["Upgrade-Insecure-Requests"] = "1"
    request["User-Agent"] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.157 Safari/537.36"
    request["Accept"] = "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3"
    request["Referer"] = "https://mlb19.theshownation.com/community_market/listings/637f65551fcad36c70e072ceb31799ba"
    request["Accept-Language"] = "en-US,en;q=0.9"
    request["Cookie"] = "mlb19_last_url=#{@@last_url_cookie}; _mlb19_web_session=#{@@web_session_cookie}"
    request.set_form_data(
      "authenticity_token" => "#{token}",
      "button" => "",
      "utf8" => "✓",
    )

    req_options = {
      use_ssl: uri.scheme == "https",
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    # update_cookie_values(response)
    response
  end

  private

  def self.update_cookie_values(response)
    binding.pry
    parsed_hash = response.header['set-cookie'].gsub('HttpOnly, ', '').split('; ').map { |e| e.split('=') }.select { |a| a.size == 2 }.to_h
    @@last_url_cookie = parsed_hash['mlb19_last_url'] unless parsed_hash['mlb_last_url'].nil?
    @@web_session_cookie = parsed_hash['_mlb19_web_session']
  end
end
