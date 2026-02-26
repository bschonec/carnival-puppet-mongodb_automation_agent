# Installs the MongoDB automation agent.
# @param package_name
#   TODO
# @param group_id
#   TODO
# @param api_key
#   TODO
# @param config_owner
#   TODO
# @param config_group
#   TODO
# @param config_mode
#   TODO
# @param base_url
#   TODO
# @param log_file
#   TODO
# @param config_backup
#   TODO
# @param log_level
#   TODO
# @param max_log_files
#   TODO
# @param max_log_file_size
#   TODO
# @param package_ensure
#   TODO

class mongodb_automation_agent (
  String $group_id,
  String $api_key,
  String $package_name = 'mongodb-mms-automation-agent-manager',
  String $config_owner = 'mongod',
  String $config_group = 'mongod',
  Stdlib::Filemode $config_mode = '0600',
  Stdlib::Httpurl $base_url = 'https://api-agents.mongodb.com',
  Stdlib::Absolutepath $log_file = '/var/log/mongodb-mms-automation/automation-agent.log',
  Stdlib::Absolutepath $config_backup='/var/lib/mongodb-mms-automation/mms-cluster-config-backup.json',
  Enum['DEBUG', 'INFO', 'WARN', 'ERROR', 'FATAL'] $log_level = 'INFO',
  Integer $max_log_files = 10,
  Integer $max_log_file_size = 268435456,
  Stdlib::Ensure::Package $package_ensure = 'installed'
) {
  # Typically, the package isn't signed so we need to stop the GPG check.
  package { $package_name:
    ensure          => $package_ensure,
    install_options => '--nogpgcheck',
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

  # Ensure service is running
  service { 'mongodb-mms-automation-agent':
    ensure  => 'running',
    enable  => true,
    require => File['mongo_agent_config'],
  }
}
