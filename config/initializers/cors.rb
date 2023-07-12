# Handling Cross-Origin Resource Sharing (CORS)
Rails.application.config.middleware.insert_before 0, Rack::Cors do
    allow do
        origins '*'

        resource '*',
                 headers: :any,
                 methods: %i[get post patch put delete options head]
    end
end
