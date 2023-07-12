class AudioConverterJob
    include Sidekiq::Job

    def perform(episode_id)
        # Retrieve the episode from the episode_id
        episode = Episode.find_by_id(episode_id)
        # Get the audio attribute (file) associated with the episode
        audio = episode.audio

        # Since the audio has been anlysed in the background, we can set the episode's duration attribute
        episode.duration = audio.metadata[:duration]

        # Transcode the audio file
        # Open the audio file
        audio.open do |file|
            # Create a FFMPEG::Movie instance of the file object
            movie = FFMPEG::Movie.new(file.path)
            # Create new location for the transcoded audio file
            path = "tmp/video-#{SecureRandom.alphanumeric(12)}.mp3"

            # This transcode is to convert a ogg audio file to mp3. This is necessary because not all browsers
            # support the ogg file format.
            movie.transcode(path, [
                                '-acodec',
                                'libmp3lame',
                                '-preset',
                                'ultrafast'
                            ])

            # After it is transcoded, replace the previous audio file with the new one
            new_filename = "#{audio.to_s.split('.ogg')[0]}.mp3"
            episode.audio.attach(io: File.open(path), filename: new_filename, content_type: audio.content_type)
        end

        # Save and apply the changes
        episode.save!
    end
end
