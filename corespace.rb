require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'
require 'yaml'


configure do
  enable :sessions
  set :session_secret, 'secret'
  set :erb, :escape_html => true
end

def data_path
  if ENV['RACK_ENV'] == 'test'
    File.expand_path('../test/data', __FILE__)
  else
    File.expand_path('../data', __FILE__)
  end
end

helpers do
  def load_yaml(file_path)
    data_file = File.open(file_path)
    yaml_file = YAML.safe_load(data_file)
  end

  def load_skills
    load_yaml(data_path + '/skills.yaml')
  end
end

get '/' do

  erb :index, layout: :layout
end

get '/skills' do
  @skills = load_skills

  erb :skills, layout: :layout
end

get '/skills/:category' do
  @skill_category = params[:category]
  @skills = load_skills
  @category = @skills[@skill_category]

  erb :skills_category, layout: :layout
end