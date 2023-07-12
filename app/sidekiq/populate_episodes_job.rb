require 'open-uri'

class PopulateEpisodesJob
    include Sidekiq::Job

    def perform(*args)
        args = args[0]

        # Create a new episode object, which will later be added to the database.
        # This uses the metadata provided as a parameter to the perform function
        episode = Episode.new(
            episode_name: args['episode_name'],
            episode_description: args['episode_description'],
            show_name: args['show_name'],
            show_description: args['show_description'],
            publication_date: args['publication_date'],
            categories: args['categories'],
            show_filename_prefix: args['show_filename_prefix'],
            episode_filename_prefix: args['episode_filename_prefix']
        )

        # Attach now the episode's image to the episode object
        image_filepath = args['image_filepath']
        extension = File.extname(image_filepath)
        episode.image.attach(
            key: "image/#{episode.episode_filename_prefix}#{extension}",
            io: URI.parse(image_filepath).open,
            filename: "#{episode.episode_filename_prefix}#{extension}",
            content_type: Rack::Mime.mime_type(extension)
        )

        # Attach now the audio. For this, download the audio file from an AWS S3 bucket.
        # The S3 bucket should have a folder named `audio-download` with the ogg file.
        # Moreover, it should also have an `audio-upload` folder, which is where the
        # attachment will be uploaded to.
        s3 = Aws::S3::Client.new(
            region: Rails.application.credentials.aws[:region],
            access_key_id: Rails.application.credentials.aws[:access_key_id],
            secret_access_key: Rails.application.credentials.aws[:secret_access_key]
        )
        begin
            resp = s3.get_object(
                bucket: Rails.application.credentials.aws[:bucket_name],
                key: "audio-download/#{episode.episode_filename_prefix}.ogg"
            )
        rescue Aws::S3::Errors::NoSuchKey
            # key was not found, so audio not available
        else
            # attach
            episode.audio.attach(
                key: "audio-upload/#{episode.episode_filename_prefix}.ogg",
                io: resp.body,
                filename: "#{episode.episode_filename_prefix}.ogg",
                content_type: Mime::Type.lookup_by_extension(:ogg)
            )
        end

        # Finally, attach the trancript. This will be used for the ElasticSearch indexing
        s3 = Aws::S3::Client.new(
            region: Rails.application.credentials.aws[:region],
            access_key_id: Rails.application.credentials.aws[:access_key_id],
            secret_access_key: Rails.application.credentials.aws[:secret_access_key]
        )

        # For the transcript, we use a trancript representation that is at a word-level.
        # Similar to audio, it requires the folder `transcripts-words-download` (and `transcripts-words-upload`)
        # to be created in the S3 bucket.
        begin
            resp = s3.get_object(
                bucket: Rails.application.credentials.aws[:bucket_name],
                key: "transcripts-words-download/#{episode.episode_filename_prefix}.vtt"
            )
        rescue Aws::S3::Errors::NoSuchKey
            # The key was not found. This means that the transcript was not available.
        else
            # This procedure is to make sure that the transcripts are all compliant and follow a similar structure.
            # For instance, Podify requires that the transcripts have a starting time of 0.
            # At the end, a vtt file containing the transcript is created and attached to the episode object.
            words_io = StringIO.new
            lines = ''
            control = false
            current_id = 1
            new_start_time = nil
            new_end_time = nil
            resp.body.each_line do |line|
                if line == "WEBVTT\n"
                    words_io.puts(line)
                else
                    case line
                    when "\n"
                        if !lines.blank? && control
                            words_io.puts(lines)
                            current_id += 1
                        end
                        lines = ''
                        control = false
                    when /\A\d+\n/
                        line = "#{current_id}\n"
                    when /\d+.\d+:\d+.\d+ --> \d+.\d+:\d+.\d+/
                        # Example line "00:00:01.000 --> 00:00:07.000\n"
                        # Let's split in two: ["00:00:01.000 ", " 00:00:07.000\n"]
                        split_line = line.split('-->')
                        line_start_time = from_string_to_seconds(split_line[0])
                        line_end_time = from_string_to_seconds(split_line[1])

                        control = true

                        # Set the starting offset. This value is used to get the transcripts start from 0, rather than from let's say 1.5 minutes.
                        # This way, the audio player will work correctly
                        start_time_offset = from_string_to_seconds(split_line[0]) unless start_time_offset.present?

                        # Update current line to remove offset in start and end times
                        new_start_time = new_start_time.present? ? Time.at(line_start_time).utc.strftime('%H:%M:%S.%L') : Time.at(0).utc.strftime('%H:%M:%S.%L')
                        new_end_time = Time.at(line_end_time).utc.strftime('%H:%M:%S.%L')
                        line = "#{new_start_time} --> #{new_end_time}\n"
                    end
                    lines += line
                end
            end
            episode.transcript_words.attach(
                key: "transcripts-words-upload/#{episode.episode_filename_prefix}.vtt",
                io: StringIO.new(words_io.string),
                filename: "#{episode.episode_filename_prefix}.vtt",
                content_type: Mime::Type.lookup_by_extension(:vtt)
            )
        end

        # Save and apply the changes
        episode.save!
    end

    private

    def from_string_to_seconds(string_to_convert)
        string_to_convert.split(':').map(&:to_f).inject(0) { |a, b| (a * 60) + b }
    end
end
