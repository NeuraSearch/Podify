ActiveAdmin.register Playlist do
    permit_params :name, :user, :current_time

    filter :name
    filter :user

    form do |f|
        f.inputs do
            f.input :name
            f.input :user
            f.input :current_time
        end
        f.actions
    end

    index download_links: false do
        selectable_column
        id_column
        column :name
        column :user
        column :selected_episode
        column :current_time
        column :created_at
        column :updated_at
        actions
    end

    show do
        attributes_table do
            row :name
            row :user
            row :selected_episode
            row :episodes
            row :current_time
            row :created_at
            row :updated_at
        end
    end
end
