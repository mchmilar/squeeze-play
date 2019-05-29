#! /usr/bin/ruby

require_relative 'player_page'
require 'byebug'
require 'pry-byebug'

class Flipper
  attr_reader :page,
    :starting_potential_profit,
    :starting_sellable,
    :starting_min_sell_price,
    :starting_max_buy_price

  class EmptyBuyOrdersError < StandardError; end
  class EmptySellOrdersError < StandardError; end
  class OrdersNotCancelledError < StandardError; end
  class NoSellableError < StandardError; end

  def initialize(player_id)
    @page = PlayerPage.new(player_id).load
    @starting_potential_profit = page.potential_profit
    @starting_sellable = page.sellable
    @starting_min_sell_price = page.min_sell_price
    @starting_max_buy_price = page.max_buy_price
  end

  def flip
    if page.sellable > 0
      p "> You already own at least one of this player, would you like to buy another?"
      @should_buy = STDIN.gets.chomp
      p "> Would you like to sell all?"
      @should_sell_all = STDIN.gets.chomp
    end
    p @should_buy
    p @should_sell_all

    p "[#{timestamp}] ### Begin flipping #{page.name} ###"
    p "[#{timestamp}] Current sellable: #{starting_sellable}"
    p "[#{timestamp}] Buy price: #{starting_max_buy_price}"
    p "[#{timestamp}] Sell price: #{starting_min_sell_price}"
    p "[#{timestamp}] Starting potential profit: #{starting_potential_profit}"
    p "[#{timestamp}] Should buy first?: #{buy?}"
    p "[#{timestamp}] Should sell all?: #{sell_all?}"
    p "[#{timestamp}] #############################################\n"

    if buy?
      page.place_max_buy_order
      page.load
      binding.pry
      p "[#{timestamp}] place order result: #{page.toastr_result.result}, #{page.toastr_result.message}"
      
      until player_acquired? || profit_margin_too_thin? do
        raise EmptyBuyOrdersError if page.buy_order.nil?
  
        if buy_order_outbid? || buy_order_matched? || overbid?
          order_prices = page.buy_orders.map { |b| b.price }
          p "[#{timestamp}] #{reorder_reason}, cancelling orders of #{order_prices}"
  
          page.cancel_buy_orders
          page.load
          p "[#{timestamp}] cancel order result: #{page.toastr_result.result}, #{page.toastr_result.message}"
          raise OrdersNotCancelledError unless page.buy_order.nil?
          p "[#{timestamp}] Cancelled orders successfully"
  
          p "[#{timestamp}] Placing max buy order"
          page.place_max_buy_order
          page.load
          p "[#{timestamp}] place order result: #{page.toastr_result.result}, #{page.toastr_result.message}"
        end
        sleep(5)
        page.load
        p "[#{timestamp}] Refreshed buy orders. My order price: #{page.buy_order&.price}, max buy price: #{page.max_buy_price&.price}, min sell price: #{page.min_sell_price&.price}, profit: #{page.potential_profit}, sellable: #{page.sellable}"
      end
  
      p "Player acquired" if player_acquired?
      p "Margin too thin" if profit_margin_too_thin?
    end

    page.load
    pre_sale_sellable = page.sellable

    raise NoSellableError if pre_sale_sellable == 0

    page.place_min_sell_order
    page.load
    p "[#{timestamp}] place order result: #{page.toastr_result.result}, #{page.toastr_result.message}"

    until sale_complete?(pre_sale_sellable)
      raise EmptySellOrdersError if page.sell_order.nil?

      if sell_order_outbid? || sell_order_matched? || underbid?
        order_prices = page.sell_orders.map { |s| s.price }
        p "[#{timestamp}] #{sell_reorder_reason}, cancelling orders of #{order_prices}"

        page.cancel_sell_orders
        page.load
        p "[#{timestamp}] cancel order result: #{page.toastr_result.result}, #{page.toastr_result.message}"
        raise OrdersNotCancelledError unless page.sell_order.nil?
        p "[#{timestamp}] Cancelled orders successfully"

        p "[#{timestamp}] Placing min sell order"
        page.place_min_sell_order
        page.load
        p "[#{timestamp}] place order result: #{page.toastr_result.result}, #{page.toastr_result.message}"
      end
      sleep(5)
      prev_sellable = page.sellable + page.sell_orders.size
      page.load
      current_sellable = page.sellable + page.sell_orders.size
      p "[#{timestamp}] Refreshed sell orders. My order price: #{page.sell_order&.price}, max buy price: #{page.max_buy_price&.price}, min sell price: #{page.min_sell_price&.price}, profit: #{page.potential_profit}, sellable: #{page.sellable}"
      p "[#{timestamp}] SOLD Card(s)! Quantity: #{prev_sellable - current_sellable}" if prev_sellable > current_sellable
    end
  end

  private

  def sale_complete?(pre_sale_sellable)
    if sell_all?
      (page.sellable + page.sell_orders.size) == 0
    else
      (pre_sale_sellable - page.sellable) == 1
    end
  end

  def sell_all?
    case @should_sell_all
    when 'n'
      false
    else
      true
    end
  end

  def buy?
    case @should_buy
    when 'n'
      false
    else
      true
    end
  end

  def reorder_reason
    if buy_order_outbid?
      'outbid'
    elsif buy_order_matched?
      'matched'
    elsif overbid?
      'overbid'
    else
      'unknown'
    end
  end

  def sell_reorder_reason
    if sell_order_outbid?
      'outbid'
    elsif sell_order_matched?
      'matched'
    elsif underbid?
      'underbid'
    else
      'unknown'
    end
  end

  def timestamp
    Time.now.strftime '%H:%M:%S'
  end

  def overbid?
    (page.buy_order.price - page.max_buy_price.price) > 1
  end

  def underbid?
    (page.min_sell_price.price - page.sell_order.price) > 1
  end

  def buy_order_matched?
    page.max_buy_price.quantity > 1
  end

  def sell_order_matched?
    page.min_sell_price.quantity > 1
  end

  def buy_order_outbid?
    page.buy_order.price < page.max_buy_price.price
  end

  def sell_order_outbid?
    page.min_sell_price.price < page.sell_order.price
  end

  def player_acquired?
    starting_sellable < page.sellable
  end

  def profit_margin_too_thin?
    (starting_potential_profit / 2) > page.potential_profit
  end
end

Flipper.new(ARGV[0]).flip