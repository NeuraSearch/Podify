# To run:
# rails episodes:seed_episodes bucket_segments_object_key="episodes.json"

namespace :episodes do
    desc 'Seed Episodes'
    task seed_episodes: [:environment] do |_task, _args|
        s3 = Aws::S3::Client.new(
            region: Rails.application.credentials.aws[:region],
            access_key_id: Rails.application.credentials.aws[:access_key_id],
            secret_access_key: Rails.application.credentials.aws[:secret_access_key]
        )

        puts('Downloading episodes RSS from S3')
        resp = s3.get_object(
            bucket: Rails.application.credentials.aws[:bucket_name],
            key: "episodes/#{ENV.fetch('bucket_segments_object_key', nil)}"
        )

        puts('Converting list of episodes to json')
        data_hash = JSON.parse(resp.body.string)

        puts('Populating database')
        data_hash.each do |episode|
            episode_name = episode['episode_name']
            image_filepath = episode['rss_information']['item']['itunes:image']['@href']
            categories = retrieve_categories(episode['rss_information']['itunes:category'])

            PopulateEpisodesJob.perform_async(
                {
                    episode_name: episode_name,
                    episode_description: episode['episode_description'],
                    show_name: episode['show_name'],
                    show_description: episode['show_description'],
                    publication_date: episode['rss_information']['item']['pubDate'],
                    categories: categories,
                    image_filepath: image_filepath,
                    show_filename_prefix: episode['show_filename_prefix'],
                    episode_filename_prefix: episode['episode_filename_prefix']
                }.stringify_keys
            )
        end
    end

    private

    def retrieve_categories(categories_hash)
        return [] unless categories_hash

        categories = []
        if categories_hash.is_a?(Array)
            categories_hash.each do |h|
                cats = []
                categories << retrieve_nested_categories(h, cats)
            end
        else
            retrieve_nested_categories(categories_hash, categories)
        end

        categories
    end

    def retrieve_nested_categories(cat_hash, categories)
        if cat_hash.is_a?(Array)
            cat_hash.each do |h|
                categories << h['@text']
            end
        else
            categories << cat_hash['@text']
            return categories unless cat_hash['itunes:category']

            retrieve_nested_categories(cat_hash['itunes:category'], categories)
        end

        categories
    end
end
