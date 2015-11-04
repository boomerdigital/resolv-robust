# Works like resolv-replace[1] in the stdlib of Ruby only it uses the extra
# robustness provided by this library. Will transparently make all DNS lookups
# use this library.
#
# 1. https://github.com/ruby/ruby/blob/trunk/lib/resolv-replace.rb

require_relative './resolv-robust'

# Let Ruby monkey-patch all the various object. Ruby will redirect everythign
# to IPSocket::getaddress.
require 'resolv-replace'

# Now redefine IPSocket::getaddress to exactly what Ruby defines it as ubt
# use `get_address_robustly` instead of `getaddress`. Injected as a prepended
# module so the monkey-patch can be removed if desired at runtime.
IPSocket.singleton_class.prepend Module.new {
  def getaddress host
    begin
      return Resolv.get_address_robustly(host).to_s
    rescue Resolv::ResolvError
      raise SocketError, "Hostname not known: #{host}"
    end
  end
}
