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
    data_file.close
    yaml_file
  end

  def load_skills
    load_yaml(data_path + '/skills.yaml')
  end
    
  def load_classes
    load_yaml(data_path + '/classes.yaml')
  end
  
  def load_class_skills(char_class)
    skills = load_skills
    all_skills_hash = {}

    skills.each_pair do |category, skills|
      skills.each_pair do |skill, details|
        all_skills_hash[skill] = details
      end
    end

    all_skills_hash.select { |skill, details|  @char_class['skills'].keys.include?(skill) } 
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

get '/skills/:category/:skill' do
  category_name = params[:category]
  skill_name = params[:skill]
  @skill = load_skills[category_name][skill_name]
  erb :skill, layout: :layout
end

get '/classes' do
  @classes = load_yaml(data_path + '/classes.yaml')
  
  erb :classes, layout: :layout
end

get '/classes/:class_name' do 
  @classes = load_classes
  @char_class = @classes[params[:class_name]]
  @class_skills = load_class_skills(@char_class)
  
  erb :class, layout: :layout
end