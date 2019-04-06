# naive implementation of verifier
class Verifier
  def initializer(filename_p)
    @filename = filename_p
    # each variable represents data of the previous block
    # to verify that the data is valid.
    @cur_line = 1
    @prev_block = -1
    @prev_time = [-1, -1]
    @prev_hash = 0
    @abort = false
  end

  def process
    File.foreach(@filename) do |line|
      verify_block(line)
      break if @abort

      @cur_line += 1
    end
  end

  def verify_block(line)
    data = line.split('|')
    return unless verify_size(data.size)
    return unless verify_block_num(data[0])
    return unless verify_block_prev_hash(data[1])
  end

  def verify_size(size)
    if size != 5
      error_out('wrong number of separators (expected: 4, actual:' + (data.size - 1).to_s + ')')
      return false
    end
    true
  end

  def verify_block_num(block_num_str)
    begin
      block_num = Integer(block_num_str)
    rescue ArgumentError
      error_out('block number was invalid (expected: integer, actual:' + size_str + ')')
      return false
    end
    if block_num != (@prev_block + 1)
      error_out('wrong block number (expected: ' + (prev_block + 1).to_s + ', actual: ' + data[0].to_s + ')')
      return false
    end
    @prev_block += 1
    true
  end

  def verify_block_prev_hash(hash_str)
    begin
      hash = Integer(hash_str, 16)
    rescue ArgumentError
      error_out('block hash was invalid (expected: hexadecimal value, actual:' + hash_str + ')')
      return false
    end
    if hash != @prev_hash
      error_out('hash did not match (expected: ' + (prev_block + 1).to_s + ', actual: ' + data[0].to_s + ')')
      return false
    end
    true
  end

  def error_out(error_message)
    @abort = true
    @result = 'Error: ' + error_message
  end
end
