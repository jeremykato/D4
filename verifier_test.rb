require 'simplecov'
SimpleCov.start

require 'minitest/autorun'
require 'parallel'
require_relative 'parallel_engine'

class VerifierTest < Minitest::Test

  def test_error_out_behavior
    v = Verifier.new(nil, 0)
    v.error_out('example error message')
    assert_output(/Line 0: example error message\nBLOCKCHAIN INVALID/) { v.put_result }
  end

  def test_bill_hash_char
    v = Verifier.new(nil, 0)
    assert_equal(v.bill_hash('a'.unpack('U*')), 6425)
  end

  def test_bill_hash_arr
    v = Verifier.new(nil, 0)
    str = '0|0|SYSTEM>281974(100)|1553188611.560418000'
    assert_equal(v.bill_hash(str.unpack('U*')), '6283'.to_i(16)) 
  end

  def test_bill_hash_empty_arr
    v = Verifier.new(nil, 0)
    str = ''
    assert_equal(v.bill_hash(str.unpack('U*')), 0)
  end

  def test_verify_block_hash_correct_match
    v = Verifier.new(nil, 0)
    data = Array.new
    data[0] = '0'
    data[1] = '0'
    data[2] = 'SYSTEM>281974(100)'
    data[3] = '1553188611.560418000'
    data[4] = '6283'
    assert v.verify_block_hash(data)
  end

  def test_verify_block_hash_wrong_match
    v = Verifier.new(nil, 0)
    data = Array.new
    data[0] = '0'
    data[1] = '0'
    data[2] = 'SYSTEM>281974(100)'
    data[3] = '1553188611.560418000'
    data[4] = '62a3'
    assert !v.verify_block_hash(data)
  end

  def test_verify_block_time_valid_time
    v = Verifier.new(nil, 0)
    assert v.verify_block_time('100.200')
    assert v.verify_block_time('200.200')
    assert v.verify_block_time('200.201')
  end

  def test_verify_block_time_invalid_time
    v = Verifier.new(nil, 0)
    assert v.verify_block_time('100.200')
    assert !v.verify_block_time('100.200')
  end

  def test_verify_block_time_invalid_format
    v = Verifier.new(nil, 0)
    assert !v.verify_block_time('100200')
  end

  def test_verify_block_time_negative_time
    v = Verifier.new(nil, 0)
    assert !v.verify_block_time('-100.200')
  end

  def test_verify_block_transactions_valid
    v = Verifier.new(nil, 0)
    assert v.verify_block_transactions('SYSTEM>281974(100)')
  end

  def test_verify_block_transactions_invalid_format1
    v = Verifier.new(nil, 0)
    assert !v.verify_block_transactions('SYSTEM>281974(100')
  end

  def test_verify_block_transactions_invalid_format2
    v = Verifier.new(nil, 0)
    assert !v.verify_block_transactions('SYSTEM>281974()100')
  end

  def test_verify_block_transactions_zero_transactions
    v = Verifier.new(nil, 0)
    assert !v.verify_block_transactions('')
  end

  def test_verify_block_transactions_negative_balance
    v = Verifier.new(nil, 0)
    assert !v.verify_block_transactions('123456>281974(100)')
  end

  def test_verify_block_transactions_invalid_recipient_address
    v = Verifier.new(nil, 0)
    assert !v.verify_block_transactions('SYSTEM>2974(100)')
  end

  def test_verify_block_transactions_invalid_sender_address
    v = Verifier.new(nil, 0)
    assert !v.verify_block_transactions('1234>297324(100)')
  end

  def test_verify_block_transactions_invalid_amount_sent
    v = Verifier.new(nil, 0)
    assert !v.verify_block_transactions('SYSTEM>297324(-100)')
  end

  def test_verify_block_prev_hash_valid
    v = Verifier.new(nil, 0)
    data = Array.new
    data[0] = '0'
    data[1] = '0'
    data[2] = 'SYSTEM>281974(100)'
    data[3] = '1553188611.560418000'
    data[4] = '6283'
    assert v.verify_block_hash(data)
    assert v.verify_block_prev_hash('6283')
  end

  def test_verify_block_prev_hash_invalid_mismatch
    v = Verifier.new(nil, 0)
    data = Array.new
    data[0] = '0'
    data[1] = '0'
    data[2] = 'SYSTEM>281974(100)'
    data[3] = '1553188611.560418000'
    data[4] = '6283'
    assert v.verify_block_hash(data)
    assert !v.verify_block_prev_hash('6233')
  end

  def test_verify_block_prev_hash_invalid_prev_hash
    v = Verifier.new(nil, 0)
    data = Array.new
    data[0] = '0'
    data[1] = '0'
    data[2] = 'SYSTEM>281974(100)'
    data[3] = '1553188611.560418000'
    data[4] = '6283'
    assert v.verify_block_hash(data)
    assert !v.verify_block_prev_hash('qqqq')
  end

  def test_verify_block_size_valid
    v = Verifier.new(nil, 0)
    assert v.verify_size(5)
  end

  def test_verify_block_size_invalid
    v = Verifier.new(nil, 0)
    assert !v.verify_size(4)
  end

  # verify block gets less tests since we already test
  # its other methods above
  def test_100_txt
    [0, 1, 2, 3].each do |p|
      v = Verifier.new(IO.readlines('input/100.txt'), p)
      v.process
      assert v.success?
    end
  end
end