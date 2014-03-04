require "digest"
require "s3"

module BundleCache
  def self.install
    architecture = `uname -m`.strip
    file_name = "#{ENV['BUNDLE_ARCHIVE']}-#{architecture}.tgz"
    digest_filename = "#{file_name}.sha2"
    bucket_name = ENV["AWS_S3_BUCKET"]
    bundle_dir = ENV["BUNDLE_DIR"] || "~/.bundle"
    processing_dir = ENV['PROCESS_DIR'] || ENV['HOME']

    s3 = S3::Service.new({
      :access_key_id => ENV["AWS_S3_KEY"],
      :secret_access_key => ENV["AWS_S3_SECRET"],
      :region => ENV["AWS_S3_REGION"] || "us-east-1"
    })
    bucket = s3.buckets.first

    gem_archive = bucket.objects.find(file_name)
    hash_object = bucket.objects.find(digest_filename)

    puts "=> Downloading the bundle"
    File.open("#{processing_dir}/remote_#{file_name}", 'wb') do |file|
      file.write(gem_archive.content(true))
    end
    puts "  => Completed bundle download"

    puts "=> Extract the bundle"
    `cd #{File.dirname(bundle_dir)} && tar -xf "#{processing_dir}/remote_#{file_name}"`

    puts "=> Downloading the digest file"
    File.open("#{processing_dir}/remote_#{file_name}.sha2", 'wb') do |file|
      file.write(hash_object.content(true))
    end
    puts "  => Completed digest download"

    puts "=> All done!"
  rescue S3::Error::NoSuchKey
    puts "There's no such archive!"
  end

end
