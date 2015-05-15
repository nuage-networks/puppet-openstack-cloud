#
# Copyright (C) 2014 eNovance SAS <licensing@enovance.com>
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# Unit tests for cloud::network::nuage-metadata class
#
require 'spec_helper'

describe 'cloud::network::nuage_metadata' do

  shared_examples_for 'openstack network nuage_metadata' do

    let :params do
      { :neutron_metadata_proxy_shared_secret => 'NuageNetworksSharedSecret',
        :nova_metadata_ip                     => '127.0.0.1',
        :nova_api_endpoint_type               => 'publicURL',
        :nova_os_username                     => 'admin',
        :nova_os_password                     => 'admin',
        :nova_os_tenant_name                  => 'demo',
        :metadata_port                        => '9697',
        :nova_metadata_port                   => '8775',
        :nova_client_version                  => '2',
        :nova_os_auth_url                     => 'http://127.0.0.1:5000/v2.0',
        :nuage_metadata_agent_starts_with_ovs => 'True',
      }
    end

    it 'configure neutron metadata' do
      is_expected.to contain_class('nuage::metadata').with(
          :nuage_metadata_port       => '9697',
	  :nuage_nova_metadata_ip    => '127.0.0.1',
	  :nuage_nova_metadata_port  => '8775',
	  :shared_secret             => 'NuageNetworksSharedSecret',
          :nuage_nova_client_version => '2',
	  :nuage_nova_os_username    => 'admin',				          :nuage_nova_os_password    => 'admin',
          :nuage_nova_os_tenant_name => 'demo',
	  :nuage_nova_os_auth_url    => 'http://127.0.0.1:5000/v2.0',

      )
    end
  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily       => 'Debian',
        :processorcount => '8' }
    end

    it_configures 'openstack network nuage_metadata'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily       => 'RedHat',
        :processorcount => '8' }
    end

    it_configures 'openstack network nuage_metadata'
  end

end
