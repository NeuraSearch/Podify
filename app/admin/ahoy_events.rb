ActiveAdmin.register Ahoy::Event do
    permit_params :visit, :user, :name, :properties, :time

    collection_action :download_csv do
        redirect_to action: :download_csv
    end

    action_item only: :index do
        link_to 'Download CSV', download_csv_admin_ahoy_events_path
    end

    controller do
        def download_csv
            respond_to do |format|
                format.html { send_data Ahoy::Event.to_csv, filename: "behaviour-#{Time.now.strftime('%Y%m%d%H%M%S')}.csv" }
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
