require 'test_helper'

class LikedEpisodesControllerTest < ActionDispatch::IntegrationTest
    test 'should get show' do
        get liked_episodes_show_url
        assert_response :success
    end
end
