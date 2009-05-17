#! /usr/bin/env ruby
# -*- coding: utf-9 -*-

require 'app'

trap :USR1 do
  ENV['comets.done'] = 'true'
  ENV['comets.msg'] = File.open('log').read
end

class Serv
  def call(env)
    ENV['comets.done'] = 'false'
    ENV['comets.msg'] = nil

    start = Time.now
    loop do
      break if (Time.now - start) > 30
      break if ENV['comets.done'] == 'true'
    end

    if ENV['comets.done'] == 'true'
      Rack::Response.new.finish do |res|
        res.write ENV['comets.msg']
      end
    else
      Rack::Response.new('', 304).finish
    end
  end
end

map '/' do
  run Sinatra::Application
end


map '/serv' do
  run Serv.new
end

