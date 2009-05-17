# -*- coding: utf-8 -*-

require File.dirname(__FILE__) + '/spec_helper'
require 'statements'

describe Statements do
  before do
  end

  after do
    Statements.destroy
  end

  [ :text, :created_at, :user ].each do |col|
    it "has #{col}" do
      Statements.new.should respond_to col
    end
  end

  it 'can make a column' do
    Statements.create do |s|
      s.text = 'statement'
      s.created_at = Time.now
      s.user = 'come'
    end
  end

  it 'can show the user friendly time format' do
    Time.stub(:now => Time.parse('2009-05-17 21:11:11'))
    statement = Statements.create(:text => 'hoge', :user => 'user', :created_at => Time.now)
    statement.time.should == '21:11'
  end
end

