module EpisodeHelper
    # Generate the breadcrumbs for the episode's categories
    def generate_categories_breadcrumb
        arrow_svg = content_tag(:svg, xmlns: 'http://www.w3.org/2000/svg', class: 'h-6 w-6', viewBox: '0 0 20 20', fill: 'currentColor') do
            "<path fill-rule='evenodd' d='M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z' clip-rule='evenodd' />".html_safe
        end

        ftag = ''
        categories = @episode.categories

        # ["Sports"] or ["Society & Culture", "Personal Journals"]
        if categories[0].is_a?(String)
            ftag += content_tag(:ol, class: 'inline-flex items-center space-x-1 md:space-x-3') do
                content_tag(:li, class: 'inline-flex items-center') { arrow_svg + content_tag(:span, class: 'text-md font-medium') { categories[0] } } +
                    safe_join(categories.drop(1).map { |n| content_tag(:li, class: 'flex items-center') { arrow_svg + content_tag(:span, class: 'ml-1 text-md font-medium md:ml-2') { n } } }).html_safe
            end
        # [["Business", "Investing"], ["Education", "Self-Improvement"]]
        else
            categories.each do |c|
                ftag += if c.is_a?(Array)
                            content_tag(:ol, class: 'inline-flex items-center space-x-1 md:space-x-3') do
                                content_tag(:li, class: 'inline-flex items-center') { arrow_svg + content_tag(:span, class: 'text-md font-medium') { c[0] } } +
                                    safe_join(c.drop(1).map { |n| content_tag(:li, class: 'flex items-center') { arrow_svg + content_tag(:span, class: 'ml-1 text-md font-medium md:ml-2') { n } } }).html_safe
                            end
                        else
                            content_tag(:li, class: 'inline-flex items-center') { arrow_svg + content_tag(:span, class: 'text-md font-medium') { c } }
                        end
            end
        end

        ftag.html_safe
    end

    # Generation for the "Like - Add To Playlist - Dislike"
    # They can be found in the episode's page
    def generate_button_svg_thumbs_and_add_to_playlist
        tup, tdown = generate_like_dislike_buttons(@episode, 14, 14)
        tadd = generate_add_to_playlist_button

        tup.concat(tadd)
        tup.concat(tdown)
    end

    private

    def generate_add_to_playlist_button
        content_tag(:div, 'data-controller': 'dropdown', class: 'relative') do
            button_tag('data-action': 'dropdown#toggle click@window->dropdown#hide') do
                content_tag(:svg, xmlns: 'http://www.w3.org/2000/svg', class: 'fill-teal-300 h-14 w-14 md:h-20 md:w-20 cursor-pointer hover:scale-125 transition transform duration-100 ease-out', viewBox: '0 0 20 20', fill: 'currentColor') do
                    "<path fill-rule='evenodd' d='M10 3a1 1 0 011 1v5h5a1 1 0 110 2h-5v5a1 1 0 11-2 0v-5H4a1 1 0 110-2h5V4a1 1 0 011-1z' clip-rule='evenodd' />".html_safe
                end
            end + content_tag(:div, 'data-dropdown-target': 'menu', class: 'absolute flex flex-col mx-3 py-2 mt-1 w-60 text-gray-800 bg-white border rounded-lg divide-y divide-gray-100 shadow hidden transition transform origin-top-right absolute left-3 md:mr-0 dark:bg-gray-700 dark:divide-gray-600">', 'data-transition-enter-from': 'opacity-0 scale-95', 'data-transition-enter-to': 'opacity-100 scale-100', 'data-transition-leave-from': 'opacity-100 scale-100', 'data-transition-leave-to': 'opacity-0 scale-95') do
                out = content_tag(:div, class: 'px-4 py-3 text-md text-center bg-blue-200 text-gray-900 dark:text-white') { 'Select a playlist:' }
                out += content_tag(:div, class: '') do
                    in_loop = ''
                    current_user.playlists.order(updated_at: :desc).each do |p|
                        in_loop << button_to(p.name, add_episode_playlist_path(playlist_id: p, episode_id: @episode), method: :post, 'data-action': 'dropdown#toggle', class: 'text-gray-700 dark:text-gray-200 w-full px-2 py-2 hover:bg-gray-200 dark:hover:bg-gray-700 dark:hover:text-white')
                    end
                    in_loop.html_safe
                end
                out.html_safe
            end
        end
    end
end
