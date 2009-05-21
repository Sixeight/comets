# -*- coding: utf-8 -*-

require 'rubygems'
require 'sequel'

Sequel::Model.plugin :schema

configure :development, :production do
  Sequel.sqlite('db/statements.db')
end

configure :test do
  Sequel.sqlite('db/test.db')
end

class Statements < Sequel::Model
  unless table_exists?
    set_schema do
      primary_key :id
      string      :text, :null => false
      string      :user, :null => false
      timestamp   :created_at
    end
    create_table
  end

  def time
    if created_at > (Time.now - 86400)
      created_at.strftime('%H:%M')
    else
      created_at.strftime('%m/%d %H:%M')
    end
  end
end

