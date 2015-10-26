require_relative './test_helper'

require_relative '../lib/resolv-robust-replace'

describe 'replacement' do
  it 'uses the robust version' do
    # Verified by artificially adjusting the cache, then verify that artificial
    # value is returned.
    Resolv.cache_store.fetch('resolv - dummy.com') { '1.1.1.2' }
    expect( IPSocket.getaddress 'dummy.com' ).must_equal '1.1.1.2'
  end
end
