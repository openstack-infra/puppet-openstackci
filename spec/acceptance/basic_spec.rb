require 'spec_helper_acceptance'

describe 'basic openstackci' do

  context 'default parameters' do

    it 'should work with no errors' do

      base_path = File.dirname(__FILE__)
      pp_path = File.join(base_path, 'fixtures', 'default.pp')
      pp = File.read(pp_path)

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

  end
end
