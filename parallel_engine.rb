# frozen_string_literal: true
require 'parallel'

# parallel implementation of verifier
class Verifier
  def initialize(lines, t_num)
    @lines = lines
    # each variable represents data of the previous block
    # to verify that the data is valid.
    @cur_line = 0
    @prev_block = -1
    @prev_time = [-1, -1]
    @prev_hash = 0
    @coin_totals = {}
    @abort = false
    @lookup = {}
    @thread = t_num
  end

  def process
    @lines.each do |line|
      verify_block(line)
      break if @abort

      @cur_line += 1
    end
  end

  def put_result
    if @abort
      puts @result_msg + "\nBLOCKCHAIN INVALID"
      return
    end
    @coin_totals.keys.sort.each do |key|
      puts key.to_s + ': ' + @coin_totals[key].to_s + ' billcoins' unless key == 'SYSTEM'
    end
  end

  def success?
    !@abort
  end

  # @precondition: line not nil
  def verify_block(line)
    data = line.split('|')
    res = true
    if @thread == 0
      res = false unless verify_size(data.size)
      res = false unless verify_block_num(data[0])
    elsif @thread == 1
      res = false unless verify_block_time(data[3])
    elsif @thread == 2
      res = false unless verify_block_transactions(data[2])
    elsif @thread == 3
      res = false unless verify_block_prev_hash(data[1])
      res = false unless verify_block_hash(data)
    end
    return unless res
  end

  # @precondition: size is integer/numeric
  def verify_size(size)
    if size != 5
      error_out('wrong number of separators (expected: 4, actual:' + (size - 1).to_s + ')')
      return false
    end
    true
  end

  # @precondition: block_num_str is string
  def verify_block_num(block_num_str)
    begin
      block_num = Integer(block_num_str)
    rescue ArgumentError
      error_out('block number was invalid (expected: integer, actual:' + size_str + ')')
      return false
    end
    if block_num != (@prev_block + 1)
      error_out('wrong block number (expected: ' + (@prev_block + 1).to_s + ', actual: ' + block_num.to_s + ')')
      return false
    end
    @prev_block += 1
    true
  end

  # @precondition: hash_str is string
  def verify_block_prev_hash(hash_str)
    begin
      hash = Integer(hash_str, 16)
    rescue ArgumentError
      error_out('block hash was invalid (expected: hexadecimal value, actual:' + hash_str + ')')
      return false
    end
    if hash != @prev_hash
      error_out('hash did not match (expected: ' + @prev_hash.to_s(16) + ', actual: ' + hash.to_s(16) + ')')
      return false
    end
    true
  end

  # @precondition: transaction_str is string
  def verify_block_transactions(transaction_str)
    transactions = transaction_str.split(':')
    if transactions.empty? || transaction_str.empty?
      error_out('block cannot have zero transactions (expected: > 1 transaction, actual: 0)')
      return false
    end
    transactions.each do |t|
      if t[-1] != ')'
        error_out('incorrect format in transaction (expected: \')\', actual: not found)')
        return false
      end
      addr_amt = t.split('(')
      addr_amt[1] = addr_amt[1].tr(')', '')
      addresses = addr_amt[0].split('>')
      if addresses[0].size != 6
        error_out('sender\'s address was an invalid length'\
        '(expected: 6, actual: ' + addresses[0].size.to_s + ')')
        return false
      elsif addresses[1].size != 6
        error_out('receipient\'s address was an invalid length'\
        '(expected: 6, actual: ' + addresses[0].size.to_s + ')')
        return false
      end
      @coin_totals[addresses[0]] = 0 if @coin_totals[addresses[0]].nil?
      @coin_totals[addresses[1]] = 0 if @coin_totals[addresses[1]].nil?
      begin
        @coin_totals[addresses[0]] -= Integer(addr_amt[1])
        @coin_totals[addresses[1]] += Integer(addr_amt[1])
        raise ArgumentError if Integer(addr_amt[1]).negative?
      rescue ArgumentError
        error_out('invalid transaction amount '\
          '(expected: positive integer, actual: ' + addr_amt[1].to_s + ')')
        return false
      end
    end
    @coin_totals.keys.each do |key|
      if @coin_totals[key].negative? && key != 'SYSTEM'
        error_out('address ' + key.to_s + ' had a negative balance'\
          '(expected: positive balance, actual: ' + @coin_totals[key].to_s + ')')
          return false
      end
    end
    true
  end

  # @precondition: time_str is string
  def verify_block_time(time_str)
    times = time_str.split('.')
    if times.size != 2
      error_out('invalid time string (expected: seconds.nanoseconds, actual: ' + time_str + ')')
      return false
    end
    begin
      times[0] = Integer(times[0])
      times[1] = Integer(times[1])
      raise ArgumentError if times[0].negative? || times[1].negative?
    rescue ArgumentError
      error_out('invalid time string (expected: seconds.nanoseconds, actual: ' + time_str + ')')
      return false
    end
    if (times[0] < @prev_time[0]) || (times[0] == @prev_time[0] && times[1] <= @prev_time[1])
      error_out('block time was earlier than previous block '\
        '(expected: at least ' + @prev_time[0].to_s + '.' + @prev_time[1].to_s + ','\
        ' actual: ' + times[0].to_s + '.' + times[1].to_s + ')')
      return false
    end
    @prev_time = times
    true
  end

  # @precondition: data_arr is array of strings
  def verify_block_hash(data_arr)
    dec_val = 0
    (0..3).each do |i|
      dec_val += bill_hash(data_arr[i].unpack('U*'))
      dec_val = dec_val % 65_536
    end
    dec_val = (dec_val + (3 * bill_hash('|'.unpack('U*')))) % 65_536
    hash = dec_val.to_s(16)
    if hash != data_arr[4].strip
      error_out('block\'s listed hash did not match actual hash value '\
        '(expected: ' + hash + ', actual: ' + data_arr[4].strip + ')')
      return false
    end
    @prev_hash = dec_val
    true
  end

  # @precondition: utf8_arr is array of integers
  def bill_hash(utf8_arr)
    total = 0
    num = 0
    utf8_arr.each do |x|
      if @lookup[x].nil?
        num = ((x.pow(3000, 65_536)) + (x.pow(x, 65_536)) - (3.pow(x, 65_536))) * (7.pow(x, 65_536))
        @lookup[x] = num % 65_536
      else
        num = @lookup[x]
      end
      total = (total + num) % 65_536
    end
    total
  end

  # @precondition: error_message is a string
  def error_out(error_message)
    @abort = true
    @result_msg = 'Line ' + @cur_line.to_s + ': ' + error_message
  end
end