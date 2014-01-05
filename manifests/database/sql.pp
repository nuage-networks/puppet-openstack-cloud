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
# MySQL Galera Node
#

class privatecloud::database::sql (
    $api_eth                   = $os_params::api_eth,
    $service_provider          = sysv,
    $galera_nextserver         = $os_params::galera_nextserver,
    $galera_master             = $os_params::galera_master,
    $mysql_password            = $os_params::mysql_password,
    $keystone_db_host          = $os_params::keystone_db_host,
    $keystone_db_user          = $os_params::keystone_db_user,
    $keystone_db_password      = $os_params::keystone_db_password,
    $keystone_db_allowed_hosts = $os_params::keystone_db_allowed_hosts,
    $cinder_db_host            = $os_params::cinder_db_host,
    $cinder_db_user            = $os_params::cinder_db_user,
    $cinder_db_password        = $os_params::cinder_db_password,
    $cinder_db_allowed_hosts   = $os_params::cinder_db_allowed_hosts,
    $glance_db_host            = $os_params::glance_db_host,
    $glance_db_user            = $os_params::glance_db_user,
    $glance_db_password        = $os_params::glance_db_password,
    $glance_db_allowed_hosts   = $os_params::glance_db_allowed_hosts,
    $heat_db_host              = $os_params::heat_db_host,
    $heat_db_user              = $os_params::heat_db_user,
    $heat_db_password          = $os_params::heat_db_password,
    $heat_db_allowed_hosts     = $os_params::heat_db_allowed_hosts,
    $nova_db_host              = $os_params::nova_db_host,
    $nova_db_user              = $os_params::nova_db_user,
    $nova_db_password          = $os_params::nova_db_password,
    $nova_db_allowed_hosts     = $os_params::nova_db_allowed_hosts,
    $neutron_db_host           = $os_params::neutron_db_host,
    $neutron_db_user           = $os_params::neutron_db_user,
    $neutron_db_password       = $os_params::neutron_db_password,
    $neutron_db_allowed_hosts  = $os_params::neutron_db_allowed_hosts,
    $mysql_password            = $os_params::mysql_password,
    $mysql_sys_maint           = $os_params::mysql_sys_maint
) {

  include 'xinetd'

  # TODO(Gonéri): OS/values detection should be moved in a params.pp
  case $::osfamily {
    'RedHat': {
        class { 'mysql':
            server_package_name => 'MariaDB-Galera-server',
            client_package_name => 'MariaDB-client',
            service_name         => 'mysql'
        }
        # galera-23.2.7-1.rhel6.x86_64
        $wsrep_provider = "/usr/lib64/galera/libgalera_smm.so"

        # TODO(Gonéri)
        # MariaDB-Galera-server-5.5.34-1.x86_64 doesn't create this
        # directory
        file { '/var/log/mysql':
            ensure => directory,
            mode   => 0750
        }

    }
    'Debian': {
        class { 'mysql':
            server_package_name => 'mariadb-galera-server',
            client_package_name => 'mariadb-client',
            service_name         => 'mysql'
        }
        $wsrep_provider = "/usr/lib/galera/libgalera_smm.so"
    }
    default: {
      err "${::osfamily} not supported yet"
    }
  }

  class { 'mysql::server':
    config_hash         => {
      bind_address      => $api_eth,
      root_password     => $mysql_password,
    },
    notify              => Service['xinetd'],
  }

  if $::hostname == $galera_master {

# OpenStack DB
    class { 'keystone::db::mysql':
      dbname        => 'keystone',
      user          => $keystone_db_user,
      password      => $keystone_db_password,
      host          => $keystone_db_host,
      allowed_hosts => $keystone_db_allowed_hosts,
    }
    class { 'glance::db::mysql':
      dbname        => 'glance',
      user          => $glance_db_user,
      password      => $glance_db_password,
      host          => $glance_db_host,
      allowed_hosts => $glance_db_allowed_hosts,
    }
    class { 'nova::db::mysql':
      dbname        => 'nova',
      user          => $nova_db_user,
      password      => $nova_db_password,
      host          => $nova_db_host,
      allowed_hosts => $nova_db_allowed_hosts,
    }

    class { 'cinder::db::mysql':
      dbname        => 'cinder',
      user          => $cinder_db_user,
      password      => $cinder_db_password,
      host          => $cinder_db_host,
      allowed_hosts => $cinder_db_allowed_hosts,
    }

    class { 'neutron::db::mysql':
      dbname        => 'neutron',
      user          => $neutron_db_user,
      password      => $neutron_db_password,
      host          => $neutron_db_host,
      allowed_hosts => $neutron_db_allowed_hosts,
    }

    class { 'heat::db::mysql':
      dbname        => 'heat',
      user          => $heat_db_user,
      password      => $heat_db_password,
      host          => $heat_db_host,
      allowed_hosts => $heat_db_allowed_hosts,
    }

# Monitoring DB
    warning('Database mapping must be updated to puppetlabs/puppetlabs-mysql >= 2.x (see: https://dev.ring.enovance.com/redmine/issues/4510)')

    database { 'monitoring':
      ensure  => 'present',
      charset => 'utf8',
      require => File['/root/.my.cnf']
    }
    database_user { 'clustercheckuser@localhost':
      ensure        => 'present',
      # can not change password in clustercheck script
      password_hash => mysql_password('clustercheckpassword!'),
      provider      => 'mysql',
      require       => File['/root/.my.cnf']
    }
    database_grant { 'clustercheckuser@localhost/monitoring':
      privileges => ['all']
    }

    Database_user<<| |>>
  }

  database_user { 'sys-maint@localhost':
    ensure        => 'present',
    password_hash => mysql_password($mysql_sys_maint),
    provider      => 'mysql',
    require       => File['/root/.my.cnf']
  }

  # set the same sys_maint password
  file{'/etc/mysql/sys.cnf':
    content => "# Automatically generated. DO NOT TOUCH!
[client]
host     = localhost
user     = sys-maint
password = ${mysql_sys_maint}
socket   = /var/run/mysqld/mysqld.sock
[mysql_upgrade]
host     = localhost
user     = sys-maint
password = ${mysql_sys_maint}
socket   = /var/run/mysqld/mysqld.sock
basedir  = /usr
",
    mode    => '0600',
  }

  # Disabled because monitor depends on checkmulti which is broken
  #  class { 'monitor::galera::httpsrv': }

  @@haproxy::balancermember{$::fqdn:
    listening_service => 'galera_cluster',
    server_names      => $::hostname,
    ipaddresses       => $api_eth,
    ports             => '3306',
    options           =>
      inline_template('check inter 2000 rise 2 fall 5 port 9200 <% if @hostname != @galera_master -%>backup<% end %>')
  }


  # TODO/WARNING(Gonéri): template changes do not trigger configuration changes
  mysql::server::config{'basic_config':
    notify_service => false,
    notify         => Exec['clean-mysql-binlog'],
    settings       => template('privatecloud/database/mysql.conf.erb')
  }

  exec{'clean-mysql-binlog':
    # first sync take a long time
    command     => '/bin/bash -c "/usr/bin/mysqladmin --defaults-file=/root/.my.cnf shutdown ; killall -9 nc ; /bin/rm -f /var/lib/mysql/ib_logfile* ; /etc/init.d/mysql start || { true ; sleep 60 ; }"',
    require     => [
      File['/root/.my.cnf'],
      Service['mysqld'],
    ],
    refreshonly => true,
  }

}
