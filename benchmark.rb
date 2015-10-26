require_relative './lib/resolv-robust'

require 'active_support/cache'
require 'redis-activesupport'
require 'benchmark'
require 'socket'
require 'thread'

HOST = 'google.com'
REPEAT = 1000
THREADS = 25

tasks = Queue.new
THREADS.times do
  Thread.new do
    while task = tasks.pop
      task.call
      Thread.main.wakeup
    end
  end
end

Benchmark.bmbm do |x|
  x.report 'system single thread' do
    REPEAT.times { IPSocket.getaddress HOST }
  end

  x.report 'resolv single thread' do
    REPEAT.times { Resolv.getaddress HOST }
  end

  x.report 'resolve in-memory cache single thread' do
    Resolv.cache_store = ActiveSupport::Cache::MemoryStore.new
    REPEAT.times { Resolv.get_address_robustly HOST }
  end

  x.report 'resolve redis cache single thread' do
    Resolv.cache_store = ActiveSupport::Cache::RedisStore.new
    Resolv.cache_store.clear
    REPEAT.times { Resolv.get_address_robustly HOST }
  end

  x.report('system thread pool') do
    REPEAT.times { tasks << -> { IPSocket.getaddress HOST } }
    Thread.stop until tasks.empty?
  end

  x.report('resolv thread pool') do
    REPEAT.times { tasks << -> { Resolv.getaddress HOST } }
    Thread.stop until tasks.empty?
  end

  x.report('resolv in-memory cache thread pool') do
    Resolv.cache_store = ActiveSupport::Cache::MemoryStore.new
    REPEAT.times { tasks << -> { Resolv.get_address_robustly HOST } }
    Thread.stop until tasks.empty?
  end

  x.report('resolv redis cache thread pool') do
    Resolv.cache_store = ActiveSupport::Cache::RedisStore.new
    Resolv.cache_store.clear
    REPEAT.times { tasks << -> { Resolv.get_address_robustly HOST } }
    Thread.stop until tasks.empty?
  end

end
