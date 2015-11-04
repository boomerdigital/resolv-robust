require 'resolv'
require 'active_support'
require 'active_support/core_ext/module/attribute_accessors'
require 'active_support/core_ext/numeric/time'

class Resolv
  mattr_accessor :cache_store
  self.cache_store = Rails.cache if defined?(Rails) && Rails.respond_to?(:cache)

  mattr_accessor :cache_duration
  self.cache_duration = 1.hour

  mattr_accessor :attempts
  self.attempts = 3

  # Same as Resolv::getaddress only it uses ActiveSuport's caching and has a
  # retry mechanism built in.
  def self.get_address_robustly name
    cache_store.fetch "resolv - #{name}", expires_in: cache_duration do
      attempts_remaining = attempts
      begin
        getaddress name
      rescue Resolv::ResolvError
        if attempts_remaining > 0
          attempts_remaining -= 1
          sleep (attempts - attempts_remaining) * 0.1
          retry
        end
        raise
      end
    end
  end

end
