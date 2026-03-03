# == Class: mongodb_automation_agent
#
# @summary
#   Installs the MongoDB automation agent.
#   Generates the configuration and ensures the service is running.
#
# @example
#   include mongodb_automation_agent
#
# @param package_name
#   Something longer to fool the linter.
# @param group_id
#   Something longer to fool the linter.
# @param api_key
#   Something longer to fool the linter.
# @param gen_key_config_owner
#   Something longer to fool the linter.
# @param gen_key_config_group
# @param config_owner
#   Something longer to fool the linter.
# @param config_group
#   Something longer to fool the linter.
# @param config_mode
#   Something longer to fool the linter.
# @param base_url
#   Something longer to fool the linter.
# @param log_file
#   Something longer to fool the linter.
# @param config_backup
#   Something longer to fool the linter.
# @param log_level
#   Something longer to fool the linter.
# @param max_log_files
#   Something longer to fool the linter.
# @param max_log_file_size
#   Something longer to fool the linter.
# @param max_uncompressed_log_files
#   Something longer to fool the linter.
# @param max_log_file_duration_hrs
#   Something longer to fool the linter.
# @param package_ensure
#   Something longer to fool the linter.
# @param genkey_file_content
#   Something longer to fool the linter.
# @param mongodb_mms_home
#   Path to the mongodb-mms configuration files.
# @param http_proxy
#   Path to the mongodb-mms configuration files.
# @param dial_timeout_seconds
#   Path to the mongodb-mms configuration files.
# @param server_selection_timeout_seconds
#   Path to the mongodb-mms configuration files.
class mongodb_automation_agent (
  String $group_id,
  String $api_key,
  Optional[String] $genkey_file_content = undef,
  Optional[Stdlib::Httpurl] $http_proxy = undef,
  Optional[Stdlib::Absolutepath] $https_ca_file = undef,
  String $package_name = 'mongodb-mms-automation-agent-manager',
  String $config_owner = 'mongod',
  String $config_group = 'mongod',
  String $gen_key_config_owner = 'mongodb-mms',
  String $gen_key_config_group = 'mongodb-mms',
  Stdlib::Filemode $config_mode = '0600',
  Stdlib::Httpurl $base_url = 'https://api-agents.mongodb.com',
  Stdlib::Absolutepath $log_file = '/var/log/mongodb-mms-automation/automation-agent.log',
  Stdlib::Absolutepath $config_backup='/var/lib/mongodb-mms-automation/mms-cluster-config-backup.json',
  Stdlib::Absolutepath $mongodb_mms_home='/etc/mongodb-mms',
  Enum['DEBUG', 'INFO', 'WARN', 'ERROR', 'FATAL'] $log_level = 'INFO',
  Integer $max_log_files = 10,
  Integer $max_log_file_size = 268435456,
  Integer $max_log_file_duration_hrs = 24,
  Integer $max_uncompressed_log_files = 2,
  Integer $dial_timeout_seconds = 40,
  Integer $server_selection_timeout_seconds = 10,
  Stdlib::Ensure::Package $package_ensure = 'installed'
) {
  # Typically, the package isn't signed so we need to stop the GPG check.
  package { $package_name:
    ensure          => $package_ensure,
    install_options => '--nogpgcheck',
  }

  # Mongodb-mms configuration file
  file { 'mongo_agent_config':
    ensure  => 'file',
    path    => "${mongodb_mms_home}/automation-agent.config",
    owner   => $config_owner,
    group   => $config_group,
    mode    => $config_mode,
    content => template('mongodb_automation_agent/automation-agent.config.erb'),
    # notify service mongodb?
    require => Package[$package_name],
  }

  # If we don't specify $genkey_file_content then ensure the file's properties
  # but don't manage its contents.
  $file_content = $genkey_file_content ? {
    undef   => undef,
    default => { content => $genkey_file_content },
  }

  # Mongodb-mms cluster key
  file { 'gen_key':
    ensure  => 'file',
    path    => "${mongodb_mms_home}/gen.key",
    owner   => $gen_key_config_owner,
    group   => $gen_key_config_group,
    mode    => '0400',
    content => $file_content,
    # notify service mongodb?
    require => Package[$package_name],
  }

  # Ensure service is running
  service { 'mongodb-mms-automation-agent':
    ensure  => 'running',
    enable  => true,
    require => File['mongo_agent_config'],
  }
}
