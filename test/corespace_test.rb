ENV["RACK_ENV"] = "test"

require 'minitest/autorun'
require 'rack/test'
require 'fileutils'


require_relative '../corespace'

class CoreSpaceTest < MiniTest::Test
  include Rack::Test::Methods
  
  def app 
    Sinatra::Application
  end
  
  def setup
  FileUtils.mkdir_p(data_path)
  FileUtils.cp('./data/skills.yaml', data_path) #have to use origin data path from root for rake test to work
  FileUtils.cp('./data/classes.yaml', data_path) #have to use origin data path from root for rake test to work
  
  end
  
  def teardown
  FileUtils.rm_rf(data_path)
  
  end

  def create_document(name, content = "")
    File.open(File.join(data_path, name), "w") do |file|
      file.write(content)
    end
  end
  
  def session
    last_request.env["rack.session"]
  end
  
  def test_index
    get '/'
    assert_equal(200, last_response.status)
  end

  def test_skills
    get '/skills'
    assert_equal(200, last_response.status)
    assert_includes(last_response.body, 'Sure Shot')
  end
  
  def test_skills_category
    get '/skills/machine'
    assert_equal(200, last_response.status)
    assert_includes(last_response.body, 'Body Protocol')
    assert_includes(last_response.body, 'Take any two actions and then lose 1 Health')
  end
  
  def test_invalid_skills_category
    get '/skills/invalid_category'
    assert_equal(302, last_response.status)
    assert_equal("invalid_category is not a valid skill category.", session[:message])
  end
  
  def test_skill_page
    get '/skills/machine/overdrive'
    assert_equal(200, last_response.status)
    assert_includes(last_response.body, "Take any two actions and then lose 1 Health")
  end
  
  def test_invalid_skill_page
    get '/skills/stealth/backstab'
    assert_equal(302, last_response.status)
    assert_equal("backstab is not a valid skill name.", session[:message])
  end
  
  def test_classes_page
    get '/classes'
    assert_equal(200, last_response.status)
    assert_includes(last_response.body, "Soldier")
    assert_includes(last_response.body, "Augmented")
    assert_includes(last_response.body, "Crewman")
  end
  
  def test_class_page
    get '/classes/support'
    assert_equal(200, last_response.status)
    assert_includes(last_response.body, "The Support is always ready to rumble")
    assert_includes(last_response.body, "Onslaught [MR 3]")
  end
  
  def test_empty_crew_page
    get '/crew'
    assert_equal(200, last_response.status)
    assert_includes(last_response.body, "Create Crew")
  end
  
  def test_save_trader
    #post '/crew/new_trader/save_trader', trader: "{'name' => 'Jugalo', 'trader_class' => 'tech', 'skills' => {} }"
    #get 'crew', crew: {'Jugalo' => {'name' => 'Jugalo', 'trader_class' => 'tech', 'skills' => {} }}
    #assert_equal(302, last_response.status)
    #assert_equal(last_response., "{'Jugalo' => {'name' => 'Jugalo', 'trader_class' => 'tech', 'skills' => {} }}")
  end
  
  def test_add_trader_page
    get '/crew/new_trader'
    assert_equal(200, last_response.status)
    assert_includes(last_response.body, "Create Trader")
  end
  
  def test_add_trader_creation
    post '/crew/new_trader', params = {t_class: 'soldier', trader_name: 'Jacob'}
    assert_equal(session[:t_class], 'soldier')
    
  end
    

end