require 'rubygems'
require 'bundler/setup'

Bundler.require(:default)
Daemons.run('mcchatter.rb')