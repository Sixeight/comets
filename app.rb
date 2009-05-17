# -*- coding: utf-9 -*-

require 'rubygems'
require 'sinatra'
require 'rack'
require 'haml'
require 'sass'

require File.dirname(__FILE__) + '/models/statements'

set :haml, { :attr_wrapper => '"',
             :escape_html => true }

enable :sessions

get '/' do
  statements = Statements.reverse_order(:created_at).
    limit(15).all.map {|s| "<li>(#{s.time}) #{s.user}: #{s.text}</li>\n" }
  @log = statements
  haml :index
end

get '/logout' do
  session[:name] = nil
  redirect '/'
end

post '/say' do
  return unless request.xhr?

  Statements.create do |s|
    s.text = params['say']
    s.user = session[:name]
    s.created_at = Time.now
  end
  Process.kill :USR1, $$
end

post '/login' do
  unless params['name'].empty?
    session[:name] = params['name']
  end
  redirect '/'
end

get '/css/application.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :application
end

