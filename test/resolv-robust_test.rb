require_relative './test_helper'

describe 'get_address_robustly' do
  # Populate cache with stubbed values and ensure those are returned
  it 'will use cached results' do
    Resolv.cache_store.fetch('resolv - fake.com') { '1.1.1.1' }
    expect( Resolv.get_address_robustly 'fake.com' ).must_equal '1.1.1.1'
  end

  it 'will retry lookup' do
    first = true
    stub = ->(*args) {
      if first
        first = false
        raise Resolv::ResolvError
      else
        '1.1.1.1'
      end
    }
    Resolv.stub :getaddress, stub do
      expect( Resolv.get_address_robustly 'fake.com' ).must_equal '1.1.1.1'
    end
  end
end
