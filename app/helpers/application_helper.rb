module ApplicationHelper
    def player_sticky_height
        80
    end

    def episode_information_formatting_with_year(date, duration)
        minutes = (duration / 60 % 60).round
        "#{date.strftime('%b').upcase} #{date.year} - #{minutes} MIN"
    end

    def episode_information_formatting_time(duration)
        Time.at(duration).utc.strftime('%H:%M:%S')
    end

    # Generation for the "Like - Dislike - Provide Feedback/Comment"
    # They can be found in the episode's page
    def generate_button_svg_thumbs_and_comment(episode, h, w)
        tup, tdown = generate_like_dislike_buttons(episode, h, w)
        tfeed = generate_feedback_button(episode, h, w)

        tup.concat(tdown)
        tup.concat(tfeed)
    end

    def generate_like_dislike_buttons(episode, h, w)
        (up, down) = up_and_down(episode)
        like_id =  "like-svg-#{episode.id}"
        dislike_id = "dislike-svg-#{episode.id}"
        click_param = "'#{like_id}', '#{dislike_id}'"

        tup = generate_tup(episode, like_id, click_param, up, h, w)
        tdown = generate_tdown(episode, dislike_id, click_param, down, h, w)

        [tup, tdown]
    end

    def generate_feedback_button(episode, h, w)
        current_comment = current_user.comments.find_by(episode_id: episode.id)
        if current_comment.present?
            button_to edit_comment_path(episode_id: episode.id, id: current_comment.id), method: :get, remote: true, data: { turbo_frame: 'commentmodal' }, title: 'Edit Feedback' do
                content_tag(:svg, xmlns: 'http://www.w3.org/2000/svg', class: "h-6 w-6 md:h-9 md:w-9 lg:h-#{h.to_i} lg:w-#{w.to_i} fill-green-500 cursor-pointer hover:scale-125 transition transform duration-100 ease-out", viewBox: '0 0 20 20', fill: 'currentColor') do
                    "<path fill-rule='evenodd' d='M18 13V5a2 2 0 00-2-2H4a2 2 0 00-2 2v8a2 2 0 002 2h3l3 3 3-3h3a2 2 0 002-2zM5 7a1 1 0 011-1h8a1 1 0 110 2H6a1 1 0 01-1-1zm1 3a1 1 0 100 2h3a1 1 0 100-2H6z' clip-rule='evenodd' />".html_safe
                end
            end
        else
            button_to new_comment_path(episode), method: :get, remote: true, data: { turbo_frame: 'commentmodal' }, title: 'Provide Feedback' do
                content_tag(:svg, xmlns: 'http://www.w3.org/2000/svg', class: "h-6 w-6 md:h-9 md:w-9 lg:h-#{h.to_i} lg:w-#{w.to_i} fill-white cursor-pointer hover:scale-125 transition transform duration-100 ease-out", viewBox: '0 0 20 20', fill: 'currentColor') do
                    "<path fill-rule='evenodd' d='M18 13V5a2 2 0 00-2-2H4a2 2 0 00-2 2v8a2 2 0 002 2h3l3 3 3-3h3a2 2 0 002-2zM5 7a1 1 0 011-1h8a1 1 0 110 2H6a1 1 0 01-1-1zm1 3a1 1 0 100 2h3a1 1 0 100-2H6z' clip-rule='evenodd' />".html_safe
                end
            end
        end
    end

    def list_playlists
        curr_playlist = @current_user.selected_playlist
        ordered_playlists = current_user.playlists.order(updated_at: :desc)
        if curr_playlist.present?
            ([curr_playlist] + (ordered_playlists - [curr_playlist]))
        else
            ordered_playlists
        end
    end

    private

    def up_and_down(episode)
        liked = liked?(episode)
        if liked.nil?
            ['', '']
        elsif liked.present?
            ['fill-blue-500', '']
        else
            ['', 'fill-red-500']
        end
    end

    def liked?(episode)
        return nil unless current_user.voted_for? episode

        current_user.voted_up_on? episode
    end

    def disliked?(episode)
        return nil unless current_user.voted_for? episode

        current_user.voted_down_on? episode
    end

    def generate_tup(episode, like_id, click_param, up, h, w)
        # If already liked, a click on like would set the state to neutral (remove vote)
        if liked?(episode)
            button_to neutral_episode_path(episode), method: :put, title: 'Remove Like From This Episode' do
                content_tag(:svg, xmlns: 'http://www.w3.org/2000/svg', id: like_id, onClick: "neutral_click(#{click_param})", class: "#{up} h-6 w-6 md:h-9 md:w-9 lg:h-#{h.to_i} lg:w-#{w.to_i} cursor-pointer hover:scale-125 transition transform duration-100 ease-out", viewBox: '0 0 20 20', fill: 'currentColor') do
                    "<path d='M2 10.5a1.5 1.5 0 113 0v6a1.5 1.5 0 01-3 0v-6zM6 10.333v5.43a2 2 0 001.106 1.79l.05.025A4 4 0 008.943 18h5.416a2 2 0 001.962-1.608l1.2-6A2 2 0 0015.56 8H12V4a2 2 0 00-2-2 1 1 0 00-1 1v.667a4 4 0 01-.8 2.4L6.8 7.933a4 4 0 00-.8 2.4z' />".html_safe
                end
            end
        else
            button_to like_episode_path(episode), method: :put, title: 'Like This Episode' do
                content_tag(:svg, xmlns: 'http://www.w3.org/2000/svg', id: like_id, onClick: "like_click(#{click_param})", class: "#{up} h-6 w-6 md:h-9 md:w-9 lg:h-#{h.to_i} lg:w-#{w.to_i} cursor-pointer hover:scale-125 transition transform duration-100 ease-out", viewBox: '0 0 20 20', fill: 'currentColor') do
                    "<path d='M2 10.5a1.5 1.5 0 113 0v6a1.5 1.5 0 01-3 0v-6zM6 10.333v5.43a2 2 0 001.106 1.79l.05.025A4 4 0 008.943 18h5.416a2 2 0 001.962-1.608l1.2-6A2 2 0 0015.56 8H12V4a2 2 0 00-2-2 1 1 0 00-1 1v.667a4 4 0 01-.8 2.4L6.8 7.933a4 4 0 00-.8 2.4z' />".html_safe
                end
            end
        end
    end

    def generate_tdown(episode, dislike_id, click_param, down, h, w)
        # If already disliked, a click on like would set the state to neutral (remove vote)
        if disliked?(episode)
            button_to neutral_episode_path(episode), method: :put, title: 'Remove Dislike From This Episode' do
                content_tag(:svg, xmlns: 'http://www.w3.org/2000/svg', id: dislike_id, onClick: "neutral_click(#{click_param})", class: "#{down} h-6 w-6 md:h-9 md:w-9 lg:h-#{h.to_i} lg:w-#{w.to_i} cursor-pointer hover:scale-125 transition transform duration-100 ease-out", viewBox: '0 0 20 20', fill: 'currentColor') do
                    "<path d='M18 9.5a1.5 1.5 0 11-3 0v-6a1.5 1.5 0 013 0v6zM14 9.667v-5.43a2 2 0 00-1.105-1.79l-.05-.025A4 4 0 0011.055 2H5.64a2 2 0 00-1.962 1.608l-1.2 6A2 2 0 004.44 12H8v4a2 2 0 002 2 1 1 0 001-1v-.667a4 4 0 01.8-2.4l1.4-1.866a4 4 0 00.8-2.4z' />".html_safe
                end
            end
        else
            button_to dislike_episode_path(episode), method: :put, title: 'Dislike This Episode' do
                content_tag(:svg, xmlns: 'http://www.w3.org/2000/svg', id: dislike_id, onClick: "dislike_click(#{click_param})", class: "#{down} h-6 w-6 md:h-9 md:w-9 lg:h-#{h.to_i} lg:w-#{w.to_i} cursor-pointer hover:scale-125 transition transform duration-100 ease-out", viewBox: '0 0 20 20', fill: 'currentColor') do
                    "<path d='M18 9.5a1.5 1.5 0 11-3 0v-6a1.5 1.5 0 013 0v6zM14 9.667v-5.43a2 2 0 00-1.105-1.79l-.05-.025A4 4 0 0011.055 2H5.64a2 2 0 00-1.962 1.608l-1.2 6A2 2 0 004.44 12H8v4a2 2 0 002 2 1 1 0 001-1v-.667a4 4 0 01.8-2.4l1.4-1.866a4 4 0 00.8-2.4z' />".html_safe
                end
            end
        end
    end

    # Helper function used to highlight in the sidebar the current page
    def current_path_selected(tpath)
        current_page?(tpath) ? 'text-green-300 font-bold underline' : ''
    end
end
