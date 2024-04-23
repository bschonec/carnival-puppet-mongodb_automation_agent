# Installs the MongoDB automation agent.

class mongodb_automation_agent (
  String $package_name = 'mongodb-mms-automation-agent-manager',
  String $group_id,
  String $api_key,
  String $config_owner = 'mongod',
  String $config_group = 'mongod',
  Stdlib::Filemode $config_mode = '0600',
  Stdlib::Httpurl $base_url = 'https://api-agents.mongodb.com',
  Stdlib::Absolutepath $log_file = '/var/log/mongodb-mms-automation/automation-agent.log',
  Stdlib::Absolutepath $config_backup='/var/lib/mongodb-mms-automation/mms-cluster-config-backup.json',
  Enum['DEBUG', 'INFO', 'WARN', 'ERROR', 'FATAL'] $log_level = 'INFO',
  Integer $max_log_files = 10,
  Integer $max_log_file_size = 268435456,
) {

  package { $package_name:
    ensure => $package_ensure,
  }

  # Generate the configuration file
  file { 'mongo_agent_config':
    ensure  => 'file',
    path    => '/etc/mongodb-mms/automation-agent.config',
    owner   => $config_owner,
    group   => $config_group,
    mode    => $config_mode,
    content => template('mongodb_automation_agent/automation-agents.config.erb'),
    require => Package[$package_name],
  }

}
