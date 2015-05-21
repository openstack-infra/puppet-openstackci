require 'spec_helper_acceptance'

describe 'basic openstackci' do

  context 'default parameters' do

    it 'should work with no errors' do

      base_path = File.dirname(__FILE__)
      pp_path = File.join(base_path, 'fixtures', 'default.pp')
      f = File.open(pp_path)
      pp = f.read
      f.close

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe port(80) do
      it { is_expected.to be_listening.with('tcp') }
    end

  end
end
