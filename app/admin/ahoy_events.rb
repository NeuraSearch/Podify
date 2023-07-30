ActiveAdmin.register Ahoy::Event do
    permit_params :visit, :user, :name, :properties, :time

    collection_action :download_csv do
        redirect_to action: :download_csv
    end

    action_item only: :index do
        link_to 'Download CSV', download_csv_admin_ahoy_events_path(format: :csv)
    end

    controller do
        def download_csv
            respond_to do |format|
                format.csv do
                    filename = "behaviour-#{Time.now.strftime('%Y%m%d%H%M%S')}.csv"
                    # Delete this header so that Rack knows to stream the content.
                    headers.delete("Content-Length")
                    # Do not cache results from this action.
                    headers["Cache-Control"] = "no-cache"
                    # Let the browser know that this file is a CSV.
                    headers['Content-Type'] = 'text/csv'
                    # Do not buffer the result when using proxy servers.
                    headers['X-Accel-Buffering'] = 'no'
                    # Set the filename
                    headers['Content-Disposition'] = "attachment; filename=\"#{filename}\""

                    headers["Last-Modified"] = Time.now.httpdate.to_s
                    response.status = 200

                    # setting the body to an enumerator, rails will iterate this enumerator
                    self.response_body = csv_enumerator
                end
            end
        end
    end

    filter :visit
    filter :user
    filter :name
    filter :time

    csv do
        column :visit_id
        column :user_id
        column :name
        column :properties
        column :time
    end

    form do |f|
        f.inputs do
            f.input :visit, include_blank: false
            f.input :user, include_blank: false
            f.input :name
            f.input :properties
            f.input :time
        end
        f.actions
    end

    index download_links: false do
        selectable_column
        id_column
        column :visit
        column :user
        column :name
        column :properties
        column :time
        actions
    end

    show do
        attributes_table do
            row :visit
            row :user
            row :name
            row :properties
            row :time
        end
    end
end
