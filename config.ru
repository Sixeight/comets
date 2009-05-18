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
        if %w[ png gif jpg ].include? $1[-3..-1]
          %[#{$`}<img src="#{$1}" width="300" />#{$'}]
        else
          %[#{$`}<a href="#{$1}">#{$1}</a>#{$'}]
        end
      when %r[\A# ]
        %[<span class="comment">#{text}</span>]
      when %r[\A#! ]
        %[<span class="shout">#{text[3..-1]}</span>]
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

