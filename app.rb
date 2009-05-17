# -*- coding: utf-9 -*-

require 'rubygems'
require 'sinatra'
require 'rack'
require 'haml'
require 'sass'

set :haml, { :attr_wrapper => '"',
             :escape_html => true }

enable :sessions

get '/' do
  @log = File.open('log').readlines
  haml :index
end

post '/say' do
  File.open('log', 'a') do |io|
    io.puts "#{params['say']}<br>"
  end
  Process.kill :USR1, $$
end

get '/css/application.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :application
end

