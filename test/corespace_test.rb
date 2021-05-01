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
  
  def test_index
    get '/'
    assert_equal(200, last_response.status)
  end

  def test_skills
    get '/skills'
    assert_equal(200, last_response.status)
    assert_includes(last_response.body, "Sure Shot")
  end
   
end