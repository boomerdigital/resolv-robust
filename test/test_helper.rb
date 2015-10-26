require 'minitest/autorun'
require 'active_support/cache'
require 'byebug'
require_relative '../lib/resolv-robust'

class Minitest::Spec
  before { Resolv.cache_store = ActiveSupport::Cache::MemoryStore.new }
end
