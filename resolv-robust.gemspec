Gem::Specification.new do |s|
  s.name = 'resolv-robust'
  s.version = '0.0.1'
  s.homepage = 'http://github.com/boomerdigital/resolv-robust'
  s.author = 'Eric Anderson'
  s.email = 'eric@boomer.digital'
  s.add_dependency 'activesupport'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'byebug'
  s.files = Dir['lib/**/*.rb']
  s.summary = 'Caching and retrying DNS resolver for robust lookups'
  s.description = <<-DESCRIPTION
    Attempts to make DNS lookups more robust by caching and retrying failed
    lookups. Also has a positive impact on the performance of DNS lookups.
  DESCRIPTION
end
