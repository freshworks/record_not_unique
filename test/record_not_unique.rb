require 'minitest/autorun'
require 'memoize_until'
require 'concurrent'

class MemoizeUntilTest < Minitest::Test

	def test_thread_safety
		clear_all_values
		latch = Concurrent::CountDownLatch.new(1)
		Thread.new { latch.wait; memoize_day(:default) { "hello world" } }
		Thread.new { latch.wait; memoize_min(:default) { "hello world" } }
		Thread.new { latch.wait; memoize_week(:default) { "hello world" } }
		latch.count_down
	end

	def test_basic_functionality
		clear_day
		memoize_day(:default) { "hello world" }
		return_val = memoize_day(:default) { 123 } # doesn't eval the block again
		assert_equal return_val, "hello world"
	end

	def test_exception
		clear_day
		assert_raises MemoizeUntil::NotImplementedError do 
			memoize_day(:new_key) { "hello world" }
		end
	end

	def test_nil
		clear_week
		memoize_week(:default) { nil }
		return_val = memoize_week(:default) { 123 }
		assert_equal return_val, nil # memoizes nil 
	end

	def test_extend
		MemoizeUntil::DAY.extend(:new_key)
		memoize_day(:new_key) { 1000 * 1000 }
		return_val = memoize_day(:new_key) { 1 }
		assert_equal return_val, 1000 * 1000
	end

	def test_memoization_expiration
		clear_min
		memoize_min(:default) { "hello world" }
		sleep(60)
		memoize_min(:default) { "hello world 2" }
		return_val = memoize_min(:default) { "hello world" }
		assert_equal return_val, "hello world 2"
	end

	private

	def memoize_day(key)
		MemoizeUntil.day(key) {
			yield
		}
	end

	def memoize_min(key)
		MemoizeUntil.min(key) {
			yield
		}
	end

	def memoize_week(key)
		MemoizeUntil.week(key) {
			yield
		}
	end

	def clear_all_values
		clear_day
		clear_min
		clear_week
	end

	def clear_day
		MemoizeUntil::DAY.send(:clear_all, :default)
	end

	def clear_min
		MemoizeUntil::MIN.send(:clear_all, :default)
	end

	def clear_week
		MemoizeUntil::WEEK.send(:clear_all, :default)
	end

end