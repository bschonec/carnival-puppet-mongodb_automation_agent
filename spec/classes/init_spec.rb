# frozen_string_literal: true

require 'spec_helper'

describe 'mongodb_automation_agent', type: :class do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        {
          group_id: '12345',
          api_key: 'ABCDefgh1234',
        }
      end

      it { is_expected.to compile }

      context 'With default parameters' do
        it {
          is_expected.to contain_package('mongodb-mms-automation-agent-manager').with(
            ensure: 'installed',
            install_options: '--nogpgcheck'
          )
          is_expected.to contain_file('mongo_agent_config').with(
            ensure: 'file',
            path: '/etc/mongodb-mms/automation-agent.config',
            owner: 'mongod',
            group: 'mongod',
            mode: '0600'
          )

          is_expected.to contain_file('mongo_agent_config').with_content(%r{mmsGroupId=12345})
          is_expected.to contain_file('mongo_agent_config').with_content(%r{mmsApiKey=ABCDefgh1234})
          is_expected.to contain_file('mongo_agent_config').with_content(%r{mmsBaseUrl=https://api-agents\.mongodb\.com})
          is_expected.to contain_file('mongo_agent_config').with_content(%r{logFile=/var/log/mongodb-mms-automation/automation-agent\.log})
          is_expected.to contain_file('mongo_agent_config').with_content(%r{mmsConfigBackup=/var/lib/mongodb-mms-automation/mms-cluster-config-backup\.json})
          is_expected.to contain_file('mongo_agent_config').with_content(%r{logLevel=INFO})
          is_expected.to contain_file('mongo_agent_config').with_content(%r{maxLogFiles=10})
          is_expected.to contain_file('mongo_agent_config').with_content(%r{maxLogFileSize=268435456})
          is_expected.to contain_file('mongo_agent_config').with_content(%r{maxLogFileDurationHrs=24})
          is_expected.to contain_file('mongo_agent_config').without_content(%r{httpProxy=})
          is_expected.to contain_file('mongo_agent_config').without_content(%r{httpsCAFile=})
          is_expected.to contain_file('mongo_agent_config').with_content(%r{maxUncompressedLogFiles=2})
          is_expected.to contain_file('mongo_agent_config').with_content(%r{dialTimeoutSeconds=40})
          is_expected.to contain_file('mongo_agent_config').with_content(%r{serverSelectionTimeoutSeconds=10})
          is_expected.to contain_file('mongo_agent_config').with_content(%r{enableLocalConfigurationServer=false})
          is_expected.to contain_file('mongo_agent_config').with_content(%r{localConfigurationServerPort=20128})

          is_expected.to contain_service('mongodb-mms-automation-agent').with(
            ensure: 'running',
            enable: true,
            require: 'File[mongo_agent_config]'
          )
        }
      end

      context 'With non-default parameters' do
        let(:params) do
          {
            group_id: 'abcde',
            api_key: 'nonDefault',
            config_owner: 'nobody',
            config_group: 'nobody',
            config_mode: '0775',
            base_url: 'https://www.example.com',
            log_file: '/var/tmp/nothing.log',
            config_backup: '/var/lib/nothing.json',
            log_level: 'DEBUG',
            max_log_files: 99,
            max_log_file_size: 123_456,
            package_ensure: 'absent',
            http_proxy: 'https://proxy.example.com:8080',
            max_log_file_duration_hrs: 1,
            max_uncompressed_log_files: 100,
            dial_timeout_seconds: 100,
            https_ca_file: '/etc/pki/tls/certs/example.crt',
            enable_local_configuration_server: true,
            local_configuration_server_port: 1234,
            server_selection_timeout_seconds: 100
          }
        end

        it {
          is_expected.to contain_package('mongodb-mms-automation-agent-manager').with(
            ensure: 'absent'
          )

          is_expected.to contain_file('mongo_agent_config').with(
            owner: 'nobody',
            group: 'nobody',
            mode: '0775'
          )

          is_expected.to contain_file('mongo_agent_config').with_content(%r{mmsGroupId=abcde})
          is_expected.to contain_file('mongo_agent_config').with_content(%r{mmsApiKey=nonDefault})
          is_expected.to contain_file('mongo_agent_config').with_content(%r{mmsBaseUrl=https://www\.example\.com})
          is_expected.to contain_file('mongo_agent_config').with_content(%r{logFile=/var/tmp/nothing\.log})
          is_expected.to contain_file('mongo_agent_config').with_content(%r{mmsConfigBackup=/var/lib/nothing\.json})
          is_expected.to contain_file('mongo_agent_config').with_content(%r{logLevel=DEBUG})
          is_expected.to contain_file('mongo_agent_config').with_content(%r{maxLogFiles=99})
          is_expected.to contain_file('mongo_agent_config').with_content(%r{maxLogFileSize=123456})
          is_expected.to contain_file('mongo_agent_config').with_content(%r{maxLogFileDurationHrs=1})
          is_expected.to contain_file('mongo_agent_config').with_content(%r{httpProxy=https://proxy.example.com:8080})
          is_expected.to contain_file('mongo_agent_config').with_content(%r{httpsCAFile=/etc/pki/tls/certs/example.crt})
          is_expected.to contain_file('mongo_agent_config').with_content(%r{maxUncompressedLogFiles=10})
          is_expected.to contain_file('mongo_agent_config').with_content(%r{dialTimeoutSeconds=100})
          is_expected.to contain_file('mongo_agent_config').with_content(%r{serverSelectionTimeoutSeconds=100})
          is_expected.to contain_file('mongo_agent_config').with_content(%r{enableLocalConfigurationServer=true})
          is_expected.to contain_file('mongo_agent_config').with_content(%r{localConfigurationServerPort=1234})

          is_expected.to contain_service('mongodb-mms-automation-agent').with(
            ensure: 'running',
            enable: true,
            require: 'File[mongo_agent_config]'
          )
        }
      end
    end
  end
end
