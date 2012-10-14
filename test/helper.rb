
$LOAD_PATH.unshift File.expand_path("../../lib/", __FILE__)

require 'rubygems'
require 'test/unit'

TEST_DATABASE_NAME = 'relaxo-test-database'
TEST_DATABASE_HOST = 'localhost:5984'

class Test::Unit::TestCase
	# Why isn't this in rails?
	def assert_includes(elem, array, message = nil)
		message = build_message message, '<?> is not found in <?>.', elem, array
		
		assert_block message do
			array.include? elem
		end
	end
end