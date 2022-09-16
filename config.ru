require "rubygems"

require "bundler/setup"

require "sinatra"

require "./app"

set :run, false
set :raise_errors, true

set :token, "ZC6EkrmtCCv0OX3SLwS0"

run Sinatra::Application
puts "Application Started!!!"