# This defined type installs Elasticsearch
define es(
  $basepath = '/opt',
  $clustername = 'elasticsearch',
  $custom_config = [],
  $datapath = 'default',
  $es_http_port_range = '9200-9299',
  $es_log_path = "/var/log/${name}",
  $es_pidpath = '/var/run',
  $es_tcp_port_range = '9300-9399',
  $es_ulimit_memlock = 'unlimited',
  $es_unicast_hosts = undef,
  $es_url = undef,
  $es_prevent_same_node_allocation = true,
  $group = 'elasticsearch',
  $javahome = '/usr/lib/jvm/java',
  $master = true,
  $multicast = true,
  $nodedata = true,
  $nodetag = '',
  $spmkey = 'none',
  $spmpath = '/spm/spm-monitor/',
  $spmversion = '1.6.0',
  $tcpcompress = false,
  $threadpools = false,
  $user = 'elasticsearch',
  $version = '0.90.3',
  $xms = '256m',
  $xmx = '2048m',
  $number_of_shards = '5',
  $number_of_replicas = '1',
  $cluster_nodes = '1',
  $minimum_master_nodes = false,
  $marvel_install = false,
  $marvel_agent = true,
  $marvel_exporter_hosts = none,
  $iostore = 'niofs',
  $disable_delete_all_indices = true,
  $indices_cache_filter_size = '10%',
  $indices_fielddata_cache_size = '10%',
  $indices_fielddata_cache_expire = '5m',
  $index_cache_filter_type = 'none',
  $index_refresh_interval = '60s',
  $cluster_concurrent_rebalance = '768',
  $disable_replica_allocation = false,
  $disable_allocation = false,
  $node_concurrent_recoveries = '32',
  $node_initial_primaries_recoveries = '64',
  $balance_threshold = '1.2',
  $routing_allocation_disk_threshold_enabled = true,
  $routing_allocation_disk_watermark_low = '0.75',
  $routing_allocation_disk_watermark_high = '0.9',
  $index_query_bool_max_clause_count = '131072',
  $index_auto_expand_replicas = false,
  $discovery_zen_ping_timeout = '30s',
  $discovery_zen_fd_ping_timeout = '30s',
  $discovery_zen_fd_ping_retries = '10',
  $discovery_zen_fd_ping_interval = '20s',
  $discovery_initial_state_timeout = '30m',
  $indices_store_throttle_type = 'none',
  $indices_recovery_max_bytes_per_sec = '512m',
  $indices_recovery_concurrent_streams = '16',
  $script_disable_dynamic = false,
) {

  $es_path  = "${basepath}/${name}"

  if $datapath == 'default'{
    $es_data_path = "${es_path}/data"
  } else {
    $es_data_path = $datapath
  }

  if $es_url {
    $es_download_url = $es_url
  } else {
    $es_download_url = "https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-${version}.tar.gz"
  }
  
  $es_download_path    = "${es_path}/elasticsearch-${version}"
  $es_pidfile          = "${es_pidpath}/${name}.pid"
  $es_xms              = $xms
  $es_xmx              = $xmx
  $es_tcp_compress     = $tcpcompress
  $es_spm_jar          = "${spmpath}/lib/spm-monitor-es-${spmversion}-withdeps.jar"
  $es_spm_config       = "${spmpath}/conf/spm-monitor-config-${spmkey}-default.xml"
  $service_name        = "elasticsearch-${name}"


  if $minimum_master_nodes {
    $minimum_master_nodes_int = $minimum_master_nodes
  } else {
    $minimum_master_nodes_int = floor($cluster_nodes / 2 + 0.5) + 1
  }

  File {
    owner => $user,
    group => $group,
  }

  $dirs = [ $es_path, $es_data_path, "${es_path}/plugin_src", $es_log_path ]
  file { $dirs: ensure => directory }->
  # Purge any unmanaged file from the plugins directory to ensure that leftover plugin
  # symlinks from previous provisionings are removed (or if their artifact id changes like for multipercolate)
  file { "${es_path}/plugins":
    ensure  => directory,
    force   => true,
    purge   => true,
    recurse => true,
    notify  => Service[$service_name],
  }->
  archive { "${name}-${version}":
    url            => $es_download_url,
    target         => $es_path,
    src_target     => $es_path,
    checksum       => false,
    allow_insecure => true,
    timeout        => 600,
    root_dir       => "elasticsearch-${version}",
  }->
  file { "${es_download_path}/config/elasticsearch.yml":
    content => template("${module_name}/elasticsearch.yml.erb"),
    notify  => Service[$service_name],
  }->
  file { "${es_download_path}/config/logging.yml":
    content => template("${module_name}/logging.yml.erb"),
    notify  => Service[$service_name],
  }->
  file { "${es_download_path}/bin/elasticsearch.in.sh":
    content => template("${module_name}/elasticsearch.in.sh.erb"),
    notify  => Service[$service_name],
  }

  file { "${es_path}/bin":
    ensure  => link,
    target  => "${es_download_path}/bin",
  }

  file { "${es_path}/config":
    ensure  => link,
    target  => "${es_download_path}/config",
  }

  file { "${es_path}/lib":
    ensure  => link,
    target  => "${es_download_path}/lib",
  }

  file { "${es_path}/logs":
    ensure  => link,
    target  => $es_log_path,
  }

  file { "/etc/${name}":
    ensure  => link,
    target  => "${es_path}/config",
  }

  file { "/etc/init.d/${service_name}":
    content => template("${module_name}/elasticsearch.init.d.erb"),
    owner   => root,
    group   => root,
    mode    => '0744',
  }

  service { $service_name:
    ensure     => running,
    enable     => true,
    hasrestart => true,
    require    => [ File["${es_path}/logs"], File["${es_path}/config"], File["${es_path}/bin"], File["${es_path}/lib"] ]
  }

  if $marvel_install {
    exec { "install_marvel_${name}":
      command => "sh -c 'cd ${es_path} && bin/plugin -i elasticsearch/marvel/latest'",
      unless  => "sh -c 'stat ${es_path}/plugins/marvel'",
      require => [ File["${es_path}/plugins"], File["${es_path}/bin"], Archive["${name}-${version}"] ],
    }
  }
}
