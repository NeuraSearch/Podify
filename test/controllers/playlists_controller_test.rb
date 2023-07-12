require 'test_helper'

class PlaylistsControllerTest < ActionDispatch::IntegrationTest
    test 'should get new' do
        get playlists_new_url
        assert_response :success
    end

    test 'should get create' do
        get playlists_create_url
        assert_response :success
    end
end
