require 'puppet-openstack_infra_spec_helper/spec_helper_acceptance'

describe 'nodepool launcher', :if => ['debian', 'ubuntu'].include?(os[:family]) do

  def pp_path
    base_path = File.dirname(__FILE__)
    File.join(base_path, 'fixtures', 'nodepool')
  end

  def preconditions_puppet_manifest
    module_path = File.join(pp_path, 'launcher-preconditions.pp')
    File.read(module_path)
  end

  def postconditions_puppet_manifest
    module_path = File.join(pp_path, 'launcher-postconditions.pp')
    File.read(module_path)
  end

  before(:all) do
    apply_manifest(preconditions_puppet_manifest, catch_failures: true)
  end

  def puppet_manifest
    module_path = File.join(pp_path, 'launcher.pp')
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

  describe command("systemctl status nodepool-launcher") do
    its(:stdout) { should contain('Active: active') }
    its(:stdout) { should_not contain('dead') }
  end

end
