ActiveAdmin.register Comment, as: 'User Comments' do
    permit_params :user, :episode, :description, :rating

    collection_action :download_csv do
        redirect_to action: :download_csv
    end

    action_item only: :index do
        link_to 'Download CSV', download_csv_admin_user_comments_path
    end

    controller do
        def download_csv
            respond_to do |format|
                format.html { send_data Comment.to_csv, filename: "comments-#{Time.now.strftime('%Y%m%d%H%M%S')}.csv" }
            end
        end
    end

    csv do
        column :id
        column :description
        column :user_id
        column :episode_id
        column :created_at
        column :updated_at
        column :rating
    end

    form do |f|
        f.inputs do
            f.input :user, include_blank: false
            f.input :episode, include_blank: false
            f.input :description
            f.input :rating
            f.actions
        end
    end

    index download_links: false do
        selectable_column
        id_column
        column :user
        column :episode
        column :description
        column :rating
        column :created_at
        column :updated_at
        actions
    end

    show do
        attributes_table do
            row :user
            row :episode
            row :description
            row :rating
            row :created_at
            row :updated_at
        end
    end
end
