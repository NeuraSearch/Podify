require 'test_helper'

class EpisodeControllerTest < ActionDispatch::IntegrationTest
    test 'should get show' do
        get episode_show_url
        assert_response :success
    end
end
