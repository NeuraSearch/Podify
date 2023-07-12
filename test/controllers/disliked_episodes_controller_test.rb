require 'test_helper'

class DislikedEpisodesControllerTest < ActionDispatch::IntegrationTest
    test 'should get show' do
        get disliked_episodes_show_url
        assert_response :success
    end
end
