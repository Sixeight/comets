#! /usr/bin/env ruby
# -*- coding: utf-9 -*-

require 'app'

trap :USR1 do
  ENV['comets.done'] = 'true'
  statements = Statements.reverse_order(:created_at).
    limit(15).all.map {|s| "<li>(#{s.time}) #{s.user}: #{s.text}</li>\n" }
  ENV['comets.msg'] = statements.join
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

