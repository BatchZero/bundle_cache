require "digest"
require "s3"

module BundleCache
  def self.cache

    acl_to_use = ENV["KEEP_BUNDLE_PRIVATE"] ? :private : :public_read
    bundle_dir = ENV["BUNDLE_DIR"] || "~/.bundle"
    processing_dir = ENV["PROCESS_DIR"] || ENV["HOME"]

    bucket_name     = ENV["AWS_S3_BUCKET"]
    architecture    = `uname -m`.strip

    file_name       = "#{ENV['BUNDLE_ARCHIVE']}-#{architecture}.tgz"
    file_path       = "#{processing_dir}/#{file_name}"
    lock_file       = File.join(File.expand_path(ENV["TRAVIS_BUILD_DIR"].to_s), "Gemfile.lock")
    digest_filename = "#{file_name}.sha2"
    old_digest      = File.expand_path("#{processing_dir}/remote_#{digest_filename}")

    puts "Checking for changes"
    bundle_digest = Digest::SHA2.file(lock_file).hexdigest
    old_digest    = File.exists?(old_digest) ? File.read(old_digest) : ""

    if bundle_digest == old_digest
      puts "=> There were no changes, doing nothing"
    else
      if old_digest == ""
        puts "=> There was no existing digest, uploading a new version of the archive"
      else
        puts "=> There were changes, uploading a new version of the archive"
        puts "  => Old checksum: #{old_digest}"
        puts "  => New checksum: #{bundle_digest}"
      end

      puts "=> Preparing bundle archive"
      `tar -C #{File.dirname(bundle_dir)} -cjf #{file_path} #{File.basename(bundle_dir)}`

      if 1 == $?.exitstatus
        puts "=> Archive failed. Please make sure '--path=#{bundle_dir}' is added to bundle_args."
        exit 1
      end


      s3 = S3::Service.new({
        :access_key_id => ENV["AWS_S3_KEY"],
        :secret_access_key => ENV["AWS_S3_SECRET"],
        :region => ENV["AWS_S3_REGION"] || "us-east-1"
      })
      bucket = s3.buckets.find(bucket_name)

      puts "=> Uploading the bundle"
      gem_archive = bucket.objects.build(file_name)
      gem_archive.content = File.read(file_path)
      gem_archive.acl = acl_to_use
      gem_archive.save

      puts "=> Uploading the digest file"
      hash_object = bucket.objects.build(digest_filename)
      hash_object.content = bundle_digest
      hash_object.acl = acl_to_use
      hash_object.content_type = "text/plain"
      hash_object.save
    end

    puts "All done now."
  end
end
