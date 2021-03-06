require 'rspec'
require 'configure-s3-website'

describe ConfigureS3Website::S3Client do
  context '#create_bucket with invalid s3_endpoint value' do
    let(:config_source) {
      mock = double('config_source')
      mock.stub(:s3_endpoint).and_return('invalid-location-constraint')
      mock
    }

    it 'throws an error' do
      expect {
        extractor = ConfigureS3Website::S3Client.
          send(:create_bucket, config_source)
      }.to raise_error(InvalidS3LocationConstraintError)
    end
  end

  context '#create_bucket with no s3_endpoint value' do
    let(:config_source) {
      ConfigureS3Website::FileConfigSource.new('spec/sample_files/_config_file.yml')
    }

    it 'calls the S3 api without request body' do
      ConfigureS3Website::HttpHelper.should_receive(:call_s3_api).
        with(anything(), anything(), '', anything())
      ConfigureS3Website::S3Client.send(:create_bucket,
                                        config_source)
    end
  end

  context '#create_bucket with s3_endpoint value' do
    let(:config_source) {
      ConfigureS3Website::FileConfigSource.new(
        'spec/sample_files/_config_file_oregon.yml'
      )
    }

    it 'calls the S3 api with location constraint XML' do
      ConfigureS3Website::HttpHelper.should_receive(:call_s3_api).
        with(anything(), anything(),
        %|
          <CreateBucketConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
            <LocationConstraint>us-west-2</LocationConstraint>
          </CreateBucketConfiguration >
         |, anything())
      ConfigureS3Website::S3Client.send(:create_bucket,
                                        config_source)
    end
  end
end
