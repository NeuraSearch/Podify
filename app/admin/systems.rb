ActiveAdmin.register System do
    permit_params :name, :experiment_id, episode_ids: []

    form do |f|
        f.inputs do
            f.input :name
            f.input :experiment
            f.input :episodes, as: :check_boxes
        end
        f.actions
    end

    index do
        selectable_column
        id_column
        column :name
        column :experiment
        column :created_at
        column :updated_at
        actions
    end

    show do
        attributes_table do
            row :name
            row :experiment
            row :episodes
            row :created_at
            row :updated_at
        end
    end
end
