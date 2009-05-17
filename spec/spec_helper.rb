# -*- coding: utf-8 -*-

$:.unshift File.dirname(__FILE__) + '/../models'

require 'rubygems'
require 'spec/interop/test'
require 'sinatra'
require 'sinatra/test'
require 'time'

Test::Unit::TestCase.__send__ :include, Sinatra::Test

set :environment, :test

