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

end