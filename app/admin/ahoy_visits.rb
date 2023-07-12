ActiveAdmin.register Ahoy::Visit do
    permit_params :user_id, :ip, :user_agent, :referrer, :referring_domain,
                  :landing_page, :browser, :os, :device_type

    collection_action :download_csv do
        redirect_to action: :download_csv
    end

    action_item only: :index do
        link_to 'Download CSV', download_csv_admin_ahoy_visits_path
    end

    controller do
        def download_csv
            respond_to do |format|
                format.html { send_data Ahoy::Visit.to_csv, filename: "visits-#{Time.now.strftime('%Y%m%d%H%M%S')}.csv" }
            end
        end
    end

    filter :user
    filter :user_agent
    filter :referrer
    filter :referring_domain
    filter :landing_page
    filter :browser
    filter :os
    filter :device_type
    filter :country

    form do |f|
        f.inputs do
            f.input :user
            f.input :ip
            f.input :user_agent
            f.input :referrer
            f.input :referring_domain
            f.input :landing_page
            f.input :browser
            f.input :os
            f.input :device_type
        end
        f.actions
    end

    index download_links: false do
        selectable_column
        id_column
        column :visit_token
        column :visitor_token
        column :user
        column :ip
        column :user_agent
        column :referrer
        column :referring_domain
        column :landing_page
        column :browser
        column :os
        column :device_type
        column :country
        actions
    end
end
