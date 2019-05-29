require 'nokogiri'
require 'open-uri'
require 'byebug'
require 'pry-byebug'
require 'mechanize'
require_relative 'player_request'
require_relative 'player_order'

class PlayerPage
  attr_reader :id,
    :name,
    :sellable,
    :owned,
    :buy_orders,
    :sell_orders,
    :buy_order_token,
    :sell_order_token,
    :max_buy_price,
    :toastr_result,
    :min_sell_price

  NAME_SELECTOR = 'body > div.site-container > div.site-canvas > div.layout-wrapper > div:nth-child(1) > div > div > div > div.widget-main.title-widget-main > h1'
  SELLABLE_SELECTOR = 'body > div.site-container > div.site-canvas > div.layout-wrapper > div:nth-child(3) > div:nth-child(2) > div > div > div > div:nth-child(2) > div > div'
  OWNED_SELECTOR = 'body > div.site-container > div.site-canvas > div.layout-wrapper > div:nth-child(3) > div:nth-child(1) > div > div > div > div:nth-child(2) > div > div'
  # BUY_ORDERS_ROWS_SELECTOR = 'html:nth-of-type(1) > body > div > div:nth-of-type(1) > div:nth-of-type(2) > div:nth-of-type(3) > div:nth-of-type(1) > div > div > div > table > tbody > tr'
  BUY_ORDERS_ROWS_SELECTOR = 'body > div.site-container > div.site-canvas > div.layout-wrapper > div:nth-child(3) > div:nth-child(1) > div > div > div > table > tbody > tr'
  SELL_ORDERS_ROWS_SELECTOR = 'html:nth-of-type(1) > body > div > div:nth-of-type(1) > div:nth-of-type(2) > div:nth-of-type(3) > div:nth-of-type(2) > div > div > div > table > tbody > tr'
  ORDER_WIDGET_SELECTOR = 'body > div.site-container > div.site-canvas > div.layout-wrapper > div:nth-child(3) > div:nth-child(1) > div > div > div'
  BUY_ORDER_TOKEN_SELECTOR = '#create-buy-order-form > input[type=hidden]:nth-child(2)'
  SELL_ORDER_TOKEN_SELECTOR = '#create-sell-order-form > input[type=hidden]:nth-child(2)'
  MAX_BUY_PRICE_SELECTOR = 'html:nth-of-type(1) > body > div > div:nth-of-type(1) > div:nth-of-type(2) > div:nth-of-type(4) > div > div > div > div:nth-of-type(2) > table > tbody > tr:nth-of-type(1)'
  MIN_SELL_PRICE_SELECTOR = 'html:nth-of-type(1) > body > div > div:nth-of-type(1) > div:nth-of-type(2) > div:nth-of-type(4) > div > div > div > div:nth-of-type(1) > table > tbody > tr:nth-of-type(1)'
  TOASTR_SELECTOR = 'body > div.site-container > div.site-canvas > script:nth-child(1)'
  BUY_PRICE_SELECTOR = ''
  SELL_PRICE_SELECTOR = ''

  OrderPrice = Struct.new(:quantity, :price)
  ToastrResult = Struct.new(:result, :message)

  class NoSellablePlayersError < StandardError; end

  def initialize(id)
    @id = id
  end

  def load
    response = PlayerRequest.get(id)
    doc = Nokogiri::HTML(response.body)
    File.open('response.html', 'w+') { |file| file.write(response.body)}
    @name = parse_name(doc)
    @sellable = parse_sellable(doc)
    @owned = parse_owned(doc)
    @buy_orders = parse_buy_orders(doc)
    @buy_order_token = parse_buy_order_token(doc)
    @sell_order_token = parse_sell_order_token(doc)
    @max_buy_price = parse_max_buy_price(doc)
    @min_sell_price = parse_min_sell_price(doc)
    @sell_orders = parse_sell_orders(doc)
    @toastr_result = parse_toastr_result(doc)
    self
  end

  def place_buy_order(price)
    PlayerRequest.create_buy_order(id, buy_order_token, price)
  end

  def place_max_buy_order
    place_buy_order(max_buy_price.price + 1)
  end

  def cancel_buy_orders
    buy_orders.map { |order| order.cancel }
  end

  def cancel_sell_orders
    sell_orders.map { |order| order.cancel }
  end

  def place_sell_order(price)
    raise(NoSellablePlayersError) if sellable < 1
    PlayerRequest.create_sell_order(id, sell_order_token, price)
  end

  def place_min_sell_order
    place_sell_order(min_sell_price.price - 1)
  end

  def potential_profit
    ((min_sell_price.price * 0.9) - max_buy_price.price).to_i
  end

  def sell_order_profit
    ((sell_orders.first.price * 0.9) - max_buy_price.price).to_i
  end

  def buy_order
    buy_orders.first
  end

  def sell_order
    sell_orders.first
  end

  private

  def parse_toastr_result(document)
    return if document.css(TOASTR_SELECTOR).empty?

    toastr_text = document.css(TOASTR_SELECTOR).children.first.inner_text
    if toastr_text.include?('toastr.success')
      result = 'success'
      message = toastr_text.split('toastr.success')[1].split("\"")[1]
    else
      result = 'error'
      message = toastr_text.split('toastr.error')[1].split("\"")[1]
    end
    ToastrResult.new(result, message)
  end

  def parse_min_sell_price(document)
    quantity = document.css(MIN_SELL_PRICE_SELECTOR).children[1].inner_text.to_i
    price = document.css(MIN_SELL_PRICE_SELECTOR).children[3].inner_text.delete("\n,").to_i
    OrderPrice.new(quantity, price)
  end

  def parse_max_buy_price(document)
    quantity = document.css(MAX_BUY_PRICE_SELECTOR).children[1].inner_text.to_i
    price = document.css(MAX_BUY_PRICE_SELECTOR).children[3].inner_text.delete("\n,").to_i
    OrderPrice.new(quantity, price)
  end

  def parse_buy_order_token(document)
    document.css(BUY_ORDER_TOKEN_SELECTOR).first['value']
  end

  def parse_sell_order_token(document)
    document.css(SELL_ORDER_TOKEN_SELECTOR).first['value']
  end

  def parse_buy_orders(document)
    rows = document.css(BUY_ORDERS_ROWS_SELECTOR)
    rows.map do |row|
      form_cell = row.children[5]
      order_id = form_cell.children[1].attributes['action'].value.split('?order_id=').last
      token = form_cell.children[1].children[1].attributes['value'].value
      price = row.children[3].children[2].inner_text.delete("\n,").to_i
      PlayerOrder.new(id: order_id, player_id: id, token: token, price: price)
    end
  end

  def parse_sell_orders(document)
    rows = document.css(SELL_ORDERS_ROWS_SELECTOR)

    rows.map do |row|
      form_cell = row.children[5]
      order_id = form_cell.children[1].attributes['action'].value.split('?order_id=').last
      token = form_cell.children[1].children[1].attributes['value'].value
      price = row.children[3].children[2].inner_text.delete("\n,").to_i
      PlayerOrder.new(id: order_id, player_id: id, token: token, price: price)
    end
  end

  def parse_name(document)
    document.css(NAME_SELECTOR).inner_text.split(/\n/).last
  end

  def parse_sellable(document)
    element = document.css(SELLABLE_SELECTOR)
    element.inner_text.delete("\n").gsub(/\s+/, '').split('|').last.to_i
  end

  def parse_owned(document)
    element = document.css(OWNED_SELECTOR)
    element.inner_text.delete("\n").gsub(/\s+/, '').split('|').last.to_i
  end
end
