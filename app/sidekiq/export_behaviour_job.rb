class ExportBehaviourJob
    include Sidekiq::Worker

    def perform
        # Create an AWS S3 instance. This used the encryped credentials. They can be accessed as follows:
        # `EDITOR="code --wait" bin/rails credentials:edit`
        s3 = Aws::S3::Resource.new(
            region: Rails.application.credentials.aws[:region],
            access_key_id: Rails.application.credentials.aws[:access_key_id],
            secret_access_key: Rails.application.credentials.aws[:secret_access_key]
        )
        # Create a new logging filename
        filename = "logging/behaviour-#{DateTime.now.strftime('%Y-%m-%d-%H-%M-%S')}.csv"
        # Create a new object in the S3 bucket
        obj = s3.bucket(Rails.application.credentials.aws[:bucket_name]).object(filename)
        # Populate the object/file with the Ahoy Events
        obj.put(body: Ahoy::Event.to_csv)
    end
end
