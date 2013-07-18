# -*- coding: utf-8 -*-

require 'rubygems'
require 'sinatra'
require 'rack'
require 'haml'
require 'sass'

require File.dirname(__FILE__) + '/models/statements'

enable :sessions
set :haml, { :attr_wrapper => '"', :escape_html => true }
set :activate?, lambda { File.exist?('activate') }
set :statements, lambda { Statements.reverse_order(:created_at) }
set :new_statement, lambda {
  statement = statements.first
  text = CometsUtils.statement_filter(statement.text)
  CometsUtils.format_statement(statement.time, statement.user, text)
}

module CometsUtils
  def statement_filter(text)
    case text
    when %r|(http://[^ ]+)|
      if %w[ png gif jpg ].include? $1[-3..-1]
        %[#{$`}<img src="#{$1}" width="300" />#{$'}]
      else
        %[#{$`}<a href="#{$1}">#{$1}</a>#{$'}]
      end
    when %r[\A# ]  then %[<span class="comment">#{text}</span>]
    when %r[\A#! ] then %[<span class="shout">#{text[3..-1]}</span>]
    else
      text
    end
  end
  module_function :statement_filter

  def format_statement(time, user, text)
    "<li>(#{time}) #{user}: #{text}</li>\n"
  end
  module_function :format_statement
end
helpers CometsUtils

trap(:USR1) { File.open('activate', 'w') }

get '/' do
  @log = options.statements.
    filter {|r| r.created_at > (Time.now - 86400) }.all.
    map {|s| format_statement(s.time, s.user, statement_filter(s.text)) }
  haml :index
end

get '/logout' do
  session[:name] = nil
  redirect '/'
end

get '/serv' do
  File.unlink('activate') if File.exist?('activate')

  # FIXME: high load
  start = Time.now
  loop do
    break if (Time.now - start) > 30
    break if options.activate?
  end

  if options.activate?
    options.new_statement
  else
    halt 304
  end
end

post '/say' do
  return unless request.xhr?
  nil while options.activate?

  Statements.create do |s|
    s.text = Rack::Utils.escape_html(params['say'])
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

