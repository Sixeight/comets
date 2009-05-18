#! /usr/bin/env ruby
# -*- coding: utf-9 -*-

require 'rubygems'
require 'sinatra'
require 'app'

module CometsUtil
  def statement_filter(text)
    res = Rack::Utils.escape_html(text)
    res = case text
      when %r|(http://[^ ]+)|
        before = $`
        after  = $'
        uri    = $1
        if %w[ png gif jpg ].include? uri[-3..-1]
          %[#{before}<img src="#{uri}" width="300" />#{after}]
        elsif %r|gist.github.com/\d+\z| =~ uri
          %[<script type="text/javascript" src="#{uri}.js"></script>]
        else
          %[#{before}<a href="#{uri}">#{uri}</a>#{after}]
        end
      else
        text
      end
    res
  end
  module_function :statement_filter
end

helpers do
  include CometsUtil
end

trap :USR1 do
  ENV['comets.done'] = 'true'

  statements = Statements.reverse_order(:created_at).
    limit(15).all.map {|s|
      text = CometsUtil.statement_filter(s.text)
      "<li>(#{s.time}) #{s.user}: #{text}</li>\n"
    }
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

