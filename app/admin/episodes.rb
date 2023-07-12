ActiveAdmin.register Episode do
    permit_params :episode_name, :episode_description, :show_name, :show_description,
                  :publication_date, :image, :transcript_words

    collection_action :download_csv do
        redirect_to action: :download_csv
    end

    action_item only: :index do
        link_to 'Download CSV', download_csv_admin_episodes_path
    end

    controller do
        def download_csv
            respond_to do |format|
                format.html { send_data Episode.to_csv, filename: "episodes-#{Time.now.strftime('%Y%m%d%H%M%S')}.csv" }
            end
        end
    end

    filter :episode_name
    filter :episode_description
    filter :show_name
    filter :show_description
    filter :publication_date
    filter :cached_votes_up
    filter :cached_votes_down

    form do |f|
        f.inputs do
            f.input :episode_name
            f.input :episode_description
            f.input :show_name
            f.input :show_description
            f.input :publication_date, include_blank: false
            f.input :show_filename_prefix
            f.input :episode_filename_prefix
            f.input :image, as: :file, hint: f.template.image_tag(url_for(f.object.image), width: 200, height: 200)
            f.input :transcript_words, as: :file
        end
        f.actions
    end

    index download_links: false do
        selectable_column
        id_column
        column :episode_name
        column :show_name
        column :publication_date
        column :categories
        column :created_at
        column :updated_at
        actions
    end

    show do |e|
        attributes_table do
            row :episode_name
            row :episode_description
            row :show_name
            row :show_description
            row :publication_date
            row :categories
            row :cached_votes_up
            row 'Liked By' do
                e.votes_for.up.voters
            end
            row :cached_votes_down
            row 'Disliked By' do
                e.votes_for.down.voters
            end
            row :image do |resource|
                image_tag(url_for(resource.image), width: 150, height: 150)
            end
            row :show_filename_prefix
            row :episode_filename_prefix
            row :created_at
            row :updated_at
        end
    end
end
