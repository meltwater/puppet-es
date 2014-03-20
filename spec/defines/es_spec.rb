require 'spec_helper'

describe 'es', :type => :define do
  Puppet::Util::Log.level = :debug
  Puppet::Util::Log.newdestination(:console)

  let(:facts) { {:osfamily => 'RedHat', :operatingsystemmajrelease => '6', :operatingsystem => 'RedHat'} }

  describe "basic instance" do
    let(:title)  { 'disk-es' }

    it { 
      should contain_es('disk-es')
      should contain_archive('disk-es-0.90.3')
      should contain_service('elasticsearch-disk-es')
    }
  end

  describe "basic instance with version" do
    let(:title)  { 'disk-es' }
    let(:params) { {:version => '1.0.0' } }

    it { 
      should contain_es('disk-es')
      should contain_archive('disk-es-1.0.0')
      should contain_service('elasticsearch-disk-es')
    }
  end
end
