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

    all_skills_hash.select { |skill, details|  char_class['skills'].keys.include?(skill) } 
  end
  
  
  
  def valid_skill_category?(skills, category_name)
      if skills[category_name].nil?
        session[:message] = "#{category_name} is not a valid skill category."
        false
      else
        true
      end
  end
  
  def valid_skill?(skills, skill_name)
    if skills[skill_name].nil?
      session[:message] = "#{skill_name} is not a valid skill name."
      false
    else
      true
    end
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
  
  redirect '/skills' unless valid_skill_category?(@skills, @skill_category)

  @category = @skills[@skill_category]
  
  erb :skills_category, layout: :layout
end

get '/skills/:category/:skill' do
  category_name = params[:category]
  skill_name = params[:skill]
  skills = load_skills
  
  redirect '/skills' unless valid_skill_category?(skills, category_name)
  redirect "/skills/#{category_name}" unless valid_skill?(skills[category_name], skill_name)
  
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

get '/crew' do
  
  erb :crew, layout: :layout
end

get '/crew/new_trader' do
  @classes = load_classes
  
  
  erb :new_trader, layout: :layout
end

post '/crew/new_trader' do
  class_name = params[:t_class]
  trader_name = params[:trader_name]
  classes = load_classes
  #selected_class = classes.select { |name, details| name == class_name }.values[0]
  selected_class = classes.select { |name, details| name == class_name }
  
  # need to verify trader_name

  session[:trader] = {'name' => trader_name, 'trader_class' => selected_class, 'skills' => {} }
  
  redirect '/crew/new_trader/select_skills'
  
end

get '/crew/new_trader/select_skills' do 
  @trader = session[:trader]
  @class_id = @trader['trader_class'].keys[0]
  @class_skills = @trader['trader_class'][@class_id]['skills']
  @available_skills = load_class_skills(@trader['trader_class'][@class_id])
  
  
  
  erb :select_skills, layout: :layout
end