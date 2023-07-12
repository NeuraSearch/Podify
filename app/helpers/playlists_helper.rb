module PlaylistsHelper
    def generate_play_button
        if @selected_playlist == @playlist
            button_tag(class: 'playBtn', type: 'button', 'data-player-target': 'play', 'data-action': 'click->player#play', 'data-info': @selected_episode.id) do
                content_tag(:svg, xmlns: 'http://www.w3.org/2000/svg', class: 'fill-teal-300 h-14 w-14 md:h-20 md:w-20 cursor-pointer hover:scale-125 transition transform duration-100 ease-out', viewBox: '0 0 20 20', fill: 'currentColor') { play_icon_path_woth_class }
            end
        elsif @playlist.episodes.empty?
            button_tag(class: 'playBtn disabled cursor-not-allowed', type: 'button') do
                content_tag(:svg, xmlns: 'http://www.w3.org/2000/svg', class: 'fill-teal-300 h-14 w-14 md:h-20 md:w-20', viewBox: '0 0 20 20', fill: 'currentColor') { play_icon_path }
            end
        else
            button_to selection_playlist_path(@playlist), data: { turbo: false }, method: :post do
                content_tag(:svg, xmlns: 'http://www.w3.org/2000/svg', class: 'fill-teal-300 h-14 w-14 md:h-20 md:w-20 cursor-pointer hover:scale-125 transition transform duration-100 ease-out', viewBox: '0 0 20 20', fill: 'currentColor') { play_icon_path }
            end
        end
    end

    def generate_episode_play_button(episode)
        if @selected_episode == episode && @selected_playlist == @playlist
            button_tag(class: 'playBtn', type: 'button', 'data-player-target': 'play', 'data-action': 'click->player#play', 'data-info': @selected_episode.id) do
                content_tag(:svg, xmlns: 'http://www.w3.org/2000/svg', class: 'fill-green-500 h-8 w-8 md:h-10 md:w-10 cursor-pointer hover:scale-125 transition transform duration-100 ease-out', viewBox: '0 0 20 20', fill: 'currentColor') { play_icon_path_woth_class }
            end
        else
            button_to episode_selection_playlist_path(playlist_id: @playlist || @selected_playlist, episode_id: episode.id), data: { turbo: false }, method: :post do
                content_tag(:svg, xmlns: 'http://www.w3.org/2000/svg', class: 'fill-green-500 h-8 w-8 md:h-10 md:w-10 cursor-pointer hover:scale-125 transition transform duration-100 ease-out', viewBox: '0 0 20 20', fill: 'currentColor') { play_icon_path }
            end
        end
    end

    # Generation for the "Like - Dislike Add To Playlist - Remove Episode From Playlist"
    # They can be found in the episode's page
    def generate_button_svg_thumbs_and_remove_from_playlist(episode)
        tup, tdown = generate_like_dislike_buttons(episode, 8, 8)
        tfeed = generate_feedback_button(episode, 8, 8)

        tdel = button_to remove_episode_playlist_path(id: @playlist, episode_id: episode), method: :post, title: 'Remove From Playlist', form: { data: { turbo_confirm: 'Are you sure?' } } do
            content_tag(:svg, xmlns: 'http://www.w3.org/2000/svg', class: 'h-6 w-6 md:h-9 md:w-9 lg:h-10 lg:w-10 fill-red-500 cursor-pointer hover:scale-125 transition transform duration-100 ease-out', viewBox: '0 0 20 20', fill: 'currentColor') do
                "<path fill-rule='evenodd' d='M9 2a1 1 0 00-.894.553L7.382 4H4a1 1 0 000 2v10a2 2 0 002 2h8a2 2 0 002-2V6a1 1 0 100-2h-3.382l-.724-1.447A1 1 0 0011 2H9zM7 8a1 1 0 012 0v6a1 1 0 11-2 0V8zm5-1a1 1 0 00-1 1v6a1 1 0 102 0V8a1 1 0 00-1-1z' clip-rule='evenodd' />".html_safe
            end
        end

        tup.concat(tdown)
        tup.concat(tfeed)
        tup.concat(tdel)
    end

    private

    def play_icon_path
        "<path fill-rule='evenodd' d='M10 18a8 8 0 100-16 8 8 0 000 16zM9.555 7.168A1 1 0 008 8v4a1 1 0 001.555.832l3-2a1 1 0 000-1.664l-3-2z' clip-rule='evenodd' />".html_safe
    end

    def play_icon_path_woth_class
        "<path class='playPath' fill-rule='evenodd' d='' clip-rule='evenodd' />".html_safe
    end
end
