class ApplicationController < ActionController::Base
    # track every page move. This is to track the journey of users when using Podify
    after_action :track_action

    protected

    def track_action
        ahoy_condition = current_user && !request.path_parameters[:controller].start_with?('admin')
        ahoy.track('navigation:page_change', request.original_url) if ahoy_condition
    end
end
