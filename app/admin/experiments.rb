ActiveAdmin.register Experiment do
    permit_params :name

    form do |f|
        f.inputs do
            f.input :name
        end
        f.actions
    end

    index do
        selectable_column
        id_column
        column :name
        column :systems
        column :created_at
        column :updated_at
        actions
    end

    show do
        attributes_table do
            row :name
            row :systems
            row :created_at
            row :updated_at
        end
    end
end
