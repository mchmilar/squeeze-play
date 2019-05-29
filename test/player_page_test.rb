require_relative '../test_helper'
require_relative '../lib/player_page'

class PlayerPageTest < Minitest::Test

  def setup
    @mike_trout_id = '42bc68623ad4f6e7df6966449f0638a8'
    @smoak_id = '637f65551fcad36c70e072ceb31799ba'
  end

  def test_load_fetches_player_name
    skip
    player_page = PlayerPage.new(@mike_trout_id).load
    assert_equal 'Mike Trout', player_page.name
  end
   
  def test_load_fetches_sellable
    skip
    player_page = PlayerPage.new(@mike_trout_id).load
    assert_equal 0, player_page.sellable
  end

  def test_load_fetches_owned
    skip
    player_page = PlayerPage.new(@mike_trout_id).load
    assert_equal 0, player_page.owned
  end

  def test_load_fetches_buy_price
    skip
    player_page = PlayerPage.new(@mike_trout_id).load
    assert_equal 0, player_page.max_buy_price.price
  end

  def test_load_fetches_buy_orders
    buy_orders = PlayerPage.new(@smoak_id).load.buy_orders
    assert_equal false, buy_orders.empty?
  end

  def test_load_fetches_sell_orders
    skip
    sell_orders = PlayerPage.new(@smoak_id).load.sell_orders
    assert_equal false, sell_orders.empty?
  end

  def test_load_fetches_buy_order_token
    skip
    page = PlayerPage.new(@smoak_id).load
    assert_equal 88, page.buy_order_token.length
  end

  def test_load_fetches_sell_order_token
    skip
    page = PlayerPage.new(@smoak_id).load
    assert_equal 88 , page.sell_order_token.length
  end

  def test_load_fetches_max_buy_price
    skip
    page = PlayerPage.new(@smoak_id).load
    assert page.max_buy_price.price > 24
    assert page.max_buy_price.quantity > 0
  end

  def test_load_fetches_min_sell_price
    skip
    page = PlayerPage.new(@smoak_id).load
    assert page.min_sell_price.price > 24
    assert page.min_sell_price.quantity > 0
  end

  def test_cancel_buy_orders_cancels_all_orders
    skip
    # You must manually create orders for the player first

    # player_page = PlayerPage.new(@smoak_id).load
    result = PlayerPage.new(@smoak_id).cancel_buy_orders
    assert_equal false, result.empty?
  end

  def test_cancel_sell_orders_cancels_all_orders
    skip
    # You must manually create orders for the player first

    result = PlayerPage.new(@smoak_id).cancel_sell_orders
    assert_equal false, result.empty?
  end

  def test_place_buy_order_succeeds
    skip
    page = PlayerPage.new(@smoak_id).load
    page.place_buy_order(25)
    assert_equal 1, page.load.buy_orders.size
  end

  def test_place_sell_order_succeeds
    skip
    page = PlayerPage.new(@smoak_id).load
    response = page.place_sell_order(300)
    assert false
  end

  def test_place_max_buy_order_places_order_1_higher
    skip
    page = PlayerPage.new(@smoak_id)
    page.cancel_buy_orders
    original_max_price = page.max_buy_price.price
    page.place_max_buy_order
    page.load
    assert_equal 1, page.buy_orders.size
    assert_equal original_max_price + 1, page.buy_orders.first.price
    page.cancel_buy_orders
    page.load
    assert_equal 0, page.buy_orders.size
  end

  def test_place_min_sell_order_places_order_1_lower
    skip
    page = PlayerPage.new(@smoak_id)
    page.cancel_sell_orders
    original_min_price = page.min_sell_price.price
    page.place_min_sell_order
    page.load
    assert_equal 1, page.sell_orders.size
    assert_equal original_min_price - 1, page.sell_orders.first.price
    page.cancel_sell_orders
    page.load
    assert_equal 0, page.sell_orders.size
  end

  def test_potential_margin
    skip
    profit = PlayerPage.new(@smoak_id).load.potential_profit
    assert true
  end

  def test_sell_order_profit
    skip
    profit = PlayerPage.new(@smoak_id).load.sell_order_profit
    assert true
  end
end
