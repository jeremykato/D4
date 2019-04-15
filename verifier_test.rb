require 'simplecov'
SimpleCov.start

require 'minitest/autorun'
require 'parallel'
require_relative 'parallel_engine'
require_relative 'verifier'

class VerifierTest < Minitest::Test

  def test_no_params
    ARGV.clear
    assert_output("Usage: ruby verifier.rb <name_of_file>
       name_of_file = name of file to verify\n") { main }
  end

  def test_invalid_file
    ARGV[0] = 'gji3qgjiwgn``riwgnrwgn0rgn0qg0nqg' # this might work if you make this file on your computer
    assert_output("Error: File was not found.\n") { main }
  end

  def test_file_100
    ARGV[0] = 'input/100.txt'
    assert_output("006586: 173 billcoins
008138: 525 billcoins
012121: 339 billcoins
050781: 123 billcoins
087095: 474 billcoins
167373: 522 billcoins
187174: 313 billcoins
195507: 531 billcoins
217151: 538 billcoins
226216: 284 billcoins
245537: 342 billcoins
268241: 227 billcoins
281974: 338 billcoins
326904: 275 billcoins
335830: 173 billcoins
338036: 262 billcoins
357621: 525 billcoins
360314: 423 billcoins
363709: 235 billcoins
443914: 86 billcoins
495699: 131 billcoins
548603: 340 billcoins
562872: 275 billcoins
669488: 162 billcoins
685223: 562 billcoins
736126: 376 billcoins
758620: 349 billcoins
778010: 468 billcoins
814708: 311 billcoins
933987: 318 billcoins
") { main }
  end
end