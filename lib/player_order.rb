class PlayerOrder
  attr_reader :id, :player_id, :token, :price

  def initialize(id:, player_id:, token:, price:)
    @id = id
    @player_id = player_id
    @token = token
    @price = price
  end

  def cancel
    PlayerRequest.cancel_order(id, player_id, token)
  end
end
