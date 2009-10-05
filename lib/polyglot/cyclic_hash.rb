class CyclicHash < Hash
  KeyValue = Struct.new( :key, :value )

  def initialize( hash )
    raise ArgumentError.new( "CyclicHash must be initialized with a hash" ) unless hash.is_a?( Hash )
    raise ArgumentError.new( "CyclicHash cannot be empty" ) if hash.empty?
    self.replace( hash )
    @current_key_idx = -1
  end

  def next!
    key = keys[next_key_idx!]
    KeyValue.new( key, self[key] )
  end

  def prev!
    key = keys[prev_key_idx!]
    KeyValue.new( key, self[key] )
  end

  protected
  def max_key_idx
    keys.length - 1
  end

  def next_key_idx!
    @current_key_idx = (@current_key_idx == max_key_idx ? 0 : @current_key_idx + 1)
  end

  def prev_key_idx!
    @current_key_idx = (@current_key_idx == 0 ? max_key_idx : @current_key_idx - 1)
  end

end
