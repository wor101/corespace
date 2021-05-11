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
    class_skill_list = load_classes[char_class]['skills']
    all_skills_hash = {}

    skills.each_pair do |category, skills|
      skills.each_pair do |skill, details|
        all_skills_hash[skill] = details
      end
    end

    all_skills_hash.select { |skill, details|  class_skill_list.include?(skill) } 
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
  @class_skills = load_class_skills(params[:class_name])
  
  erb :class, layout: :layout
end

get '/crew' do
  session.delete(:trader) unless session[:trader].nil?
  
  erb :crew, layout: :layout
end

get '/crew/new_trader' do
  @classes = load_classes
  session.delete(:trader) unless session[:trader].nil?
  
  erb :new_trader, layout: :layout
end

post '/crew/new_trader' do
  class_name = params[:t_class]
  trader_name = params[:trader_name]
  classes = load_classes
  selected_class = classes.select { |name, details| name == class_name }
  
  # need to verify trader_name
  #session.delete(:trader) unless session[:trader].nil?
  session[:trader] = {'name' => trader_name, 'trader_class' => class_name, 'skills' => {} }
  
  redirect '/crew/new_trader/select_skills'
  
end

get '/crew/new_trader/select_skills' do 
  redirect '/crew/new_trader' if session[:trader].nil?
 
  @trader = session[:trader]

  classes = load_classes
  trader_class = classes[@trader['trader_class']]
  
  
  @class_skills = trader_class['skills']
  @available_skills = load_class_skills(@trader['trader_class'])
  
  erb :select_skills, layout: :layout
end

post '/crew/new_trader/select_skills' do
  @trader = session[:trader]
  selected_skill = params['skill_name']
  skill_level = params['skill_level']
  @trader['skills'][selected_skill] = skill_level
  session[:trader] = @trader
  
  redirect '/crew/new_trader/select_skills'
end

post '/crew/new_trader/save_trader' do
  trader_name = session[:trader]['name']
  if session[:crew].nil? || session[:crew].empty?
    session[:crew] = { trader_name => session[:trader] }
  else
    session[:crew][trader_name] = session[:trader]
  end
  session.delete(:trader)
  
  redirect '/crew'
end

post '/crew/delete_trader' do
  session[:crew].delete(params[:delete_name])
  
  redirect '/crew'
end

post '/test_params' do
  param1 = params[:param1]
  session1 = session[:sess1]
  
  #p param1.to_s
  p session1.to_s
end