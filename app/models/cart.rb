class Cart
  attr_reader :contents

  def initialize(cart_session_hash)
    @contents = cart_session_hash || Hash.new(0)
  end

  def add_item(item_id)
    @contents[item_id.to_s] = count_of(item_id.to_s) + 1
  end

  def total_count
    @contents.values.sum
  end

  def count_of(item_id)
    @contents[item_id.to_s].to_i
  end

  def item_and_quantity_hash
    @contents.map do |item_id, quantity|
      [Item.find(item_id.to_i), quantity]
    end.to_h
  end

  def subtotal(item)
    quantity = item_and_quantity_hash[item]
    item.bulk_price(quantity) * quantity
  end

  def grand_total
    item_and_quantity_hash.sum do |item, quantity|
      item.bulk_price(quantity) * quantity
    end
  end

  def is_not_empty
    @contents.keys.any?
  end

  def remove_item(item_id)
    @contents[item_id.to_s] = count_of(item_id.to_s) - 1
    if @contents[item_id.to_s] <= 0
      @contents.delete(item_id.to_s)
    end
  end

  def remove_all_item(item_id)
    @contents.delete(item_id.to_s)
  end

end
