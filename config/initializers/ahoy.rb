module Ahoy
    class Store < Ahoy::DatabaseStore
        def authenticate(data)
            # disables automatic linking of visits and users
        end
    end
end

Ahoy.api = true
Ahoy.server_side_visits = :when_needed
Ahoy.cookie_domain = :all
Ahoy.geocode = true

# GDPR Compliance
Ahoy.mask_ips = true
Ahoy.cookies = false
