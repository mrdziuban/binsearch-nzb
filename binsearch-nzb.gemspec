require File.dirname(__FILE__) + '/lib/binsearch-nzb/version.rb'

Gem::Specification.new do |s|
  s.name     = 'binsearch-nzb'
  s.version  = BinsearchNzb::VERSION
  s.date     = BinsearchNzb::VERSION_DATE

  s.summary  = ''
  s.homepage = 'https://github.com/mrdziuban/binsearch-nzb'
  s.authors  = ['Matt Dziuban']
  s.email    = 'mrdziuban@gmail.com'

  s.files    = Dir['lib/**/*'] + ['binsearch-nzb.gemspec']
  s.require_path = 'lib'

  s.required_ruby_version = '>= 1.9'

  s.add_dependency 'nokogiri', '>= 1.6.6'
end
