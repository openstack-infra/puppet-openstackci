require 'puppet-openstack_infra_spec_helper/spec_helper_acceptance'

describe 'nodepool builder', :if => (
    ['debian', 'ubuntu'].include?(os[:family]) &&
    # builder is not expected to work with python < 3.5 since its config
    # depends on math.inf
     os[:release] >= '16.04'
  ) do

  def pp_path
    base_path = File.dirname(__FILE__)
    File.join(base_path, 'fixtures', 'nodepool')
  end

  def preconditions_puppet_manifest
    module_path = File.join(pp_path, 'builder-preconditions.pp')
    File.read(module_path)
  end

  def postconditions_puppet_manifest
    module_path = File.join(pp_path, 'builder-postconditions.pp')
    File.read(module_path)
  end

  before(:all) do
    apply_manifest(preconditions_puppet_manifest, catch_failures: true)
  end

  def puppet_manifest
    module_path = File.join(pp_path, 'builder.pp')
    File.read(module_path)
  end

  it 'should work with no errors' do
    apply_manifest(puppet_manifest, catch_failures: true)
  end

  it 'should be idempotent' do
    apply_manifest(puppet_manifest, catch_changes: true)
  end

  it 'should start' do
    apply_manifest(postconditions_puppet_manifest, catch_failures: true)
  end

  describe command("systemctl status nodepool-builder") do
    its(:stdout) { should contain('Active: active') }
    its(:stdout) { should_not contain('dead') }
  end

end
