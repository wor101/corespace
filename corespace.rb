require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'
require 'yaml'
require 'bcrypt'

configure do
  enable :sessions
  set :session_secret, 'secret'
  set :erb, :escape_html => true
end

get '/' do

  erb :index
end