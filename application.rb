require 'rubygems'
require 'sinatra'
# require 'erb'
require 'sinatra/static_assets'
# require 'sqlite3'
require 'dm-core'
require 'dm-migrations'

configure :development do
  ## Run
  # sqlite3 test.db "create table mailing_lists (id INTEGER PRIMARY KEY, email STRING, created_at DATETIME);"
  
  DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/test.db")
  DataMapper.auto_upgrade!
end

configure :production do
  ## ENV['DATABASE_URL'] is provided by heroku for connecting to their Postgres db
  ## See this for more info - http://docs.heroku.com/database#using-the-databaseurl-environment-variable-sequel--datamapper
  DataMapper::setup(:default, ENV['DATABASE_URL'] || 'sqlite3://application.db')
end

class MailingList
  include DataMapper::Resource
  property :id,         Serial
  property :email,      String, :length => 150
  property :created_at, DateTime
end

DataMapper.finalize

get '/' do
  @list = MailingList.all.count
  erb :index
end

get '/thanks' do
  erb :thanks
end

post '/subscribe' do
  email = params[:subscribe][:email]
  
  unless email.blank? || email == 'Enter your email address'
    MailingList.create(:email => email, :created_at => Time.now.utc)
  end
  
  redirect '/thanks'
end