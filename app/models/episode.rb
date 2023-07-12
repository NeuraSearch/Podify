class Episode < ApplicationRecord
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks
    include ActionView::Helpers::TextHelper

    has_many :comments
    has_many :users, through: :comments
    has_many :episode_playlists
    has_many :playlists, through: :episode_playlists

    has_one_attached :image
    has_one_attached :audio
    has_one_attached :transcript_words

    has_and_belongs_to_many :systems

    serialize :categories

    validates :episode_name, presence: true
    validates :show_name, presence: true
    validates :publication_date, presence: true
    validates :episode_filename_prefix, presence: true

    # After an episode is created and commited, the audio file is converted
    # A background job is created for it, and performed in the background: AudioConverterJob
    after_commit :convert_audio, on: :create

    # Enable the storing of like/dislike in the database
    acts_as_votable

    # ElasticSearch setup
    def as_indexed_json(_options = {})
        # Get transcript representation as full-text
        words_transcript = simple_format(transcript_words.blob.download)
        words_transcript.slice!("<p>WEBVTT</p>\n\n")
        words_transcript.gsub!(%r{<p>\d+\n<br />}, '')
        words_transcript.gsub!(/\d+:\d+:\d+.\d+/, '')
        words_transcript.gsub!(%r{ --&gt; \n<br />}, '')
        words_transcript.gsub!(%r{</p>\n\n}, '')
        words_transcript.gsub!(%r{</p>}, '')

        # Convert episode record to json and then append the full-text transcript to it
        json_object = as_json
        json_object['transcript'] = words_transcript
        json_object
    end

    settings index: { number_of_shards: 1 } do
        mapping dynamic: false do
            indexes :id, type: :long
            indexes :episode_name, analyzer: 'snowball'
            indexes :episode_description, analyzer: 'snowball'
            indexes :show_name, analyzer: 'snowball'
            indexes :show_description, analyzer: 'snowball'
            indexes :transcript, analyzer: 'snowball'
        end
    end

    def self.search(query)
        __elasticsearch__.search(
            {
                size: 50,
                query: {
                    multi_match: {
                        query: query,
                        fields: [
                            'transcript^2', 'episode_name', 'episode_description',
                            'show_name', 'show_description'
                        ]
                    }
                }
            }
        )
    end

    def display_name
        episode_name
    end

    # This function is called when exporting the episodes list to a CSV file
    def self.to_csv
        CSV.generate do |csv|
            csv << (column_names + %w[transcript_words])
            Episode.all.each do |episode|
                row = episode.attributes.values_at(*column_names)
                row += [episode.transcript_words.attached?]
                csv << row
            end
        end
    end

    private

    def convert_audio
        AudioConverterJob.perform_async(id)
    end

    def from_string_to_seconds(string_to_convert)
        string_to_convert.split(':').map(&:to_f).inject(0) { |a, b| (a * 60) + b }
    end
end
