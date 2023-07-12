ActiveAdmin.register User do
    permit_params :username, :system_id

    filter :username

    form do |f|
        f.inputs do
            f.input :username
            f.input :system
        end
        f.actions
    end

    index download_links: false do
        selectable_column
        id_column
        column :username
        column :system
        column :selected_playlist
        column :current_sign_in_at
        column :sign_in_count
        column :created_at
        column :updated_at
        actions
    end

    show do |u|
        attributes_table do
            row :username
            row :system
            row :episode
            row '# Likes' do
                u.find_up_voted_items.count
            end
            row :liked_items do
                u.find_liked_items
            end
            row '# Dislikes' do
                u.find_down_voted_items.count
            end
            row :disliked_items do
                u.find_disliked_items
            end
            row :selected_playlist
            row :playlists
            row :created_at
            row :updated_at
        end
    end
end
