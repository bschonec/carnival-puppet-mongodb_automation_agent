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
          is_expected.to contain_file('gen_key').with(
            ensure: 'file',
            path: '/etc/mongodb-mms/gen.key',
            owner: 'mongodb-mms',
            group: 'mongodb-mms',
            mode: '0400'
          )

          is_expected.to contain_file('mongo_agent_config').with_content(/mmsGroupId=12345/)
          is_expected.to contain_file('mongo_agent_config').with_content(/mmsApiKey=ABCDefgh1234/)
          is_expected.to contain_file('mongo_agent_config').with_content(/mmsBaseUrl=https:\/\/api-agents\.mongodb\.com/)
          is_expected.to contain_file('mongo_agent_config').with_content(/logFile=\/var\/log\/mongodb\-mms\-automation\/automation-agent\.log/)
          is_expected.to contain_file('mongo_agent_config').with_content(/mmsConfigBackup=\/var\/lib\/mongodb\-mms\-automation\/mms\-cluster\-config\-backup\.json/)
          is_expected.to contain_file('mongo_agent_config').with_content(/logLevel=INFO/)
          is_expected.to contain_file('mongo_agent_config').with_content(/maxLogFiles=10/)
          is_expected.to contain_file('mongo_agent_config').with_content(/maxLogFileSize=268435456/)
          is_expected.to contain_file('mongo_agent_config').with_content(/httpProxy=/)

          is_expected.to contain_service('mongodb-mms-automation-agent').with(
            ensure: 'running',
            enable: true,
            require: 'File[mongo_agent_config]',
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
            max_log_file_size: 123456,
            package_ensure: 'absent',
            genkey_file_content: 'Hello, world'
          }
        end

        it {
          is_expected.to contain_package('mongodb-mms-automation-agent-manager').with(
            ensure: 'absent'
          )

          is_expected.to contain_file('gen_key').with_content(/Hello, world/)

          is_expected.to contain_file('mongo_agent_config').with(
            owner: 'nobody',
            group: 'nobody',
            mode: '0775'
          )

          is_expected.to contain_file('mongo_agent_config').with_content(/mmsGroupId=abcde/)
          is_expected.to contain_file('mongo_agent_config').with_content(/mmsApiKey=nonDefault/)
          is_expected.to contain_file('mongo_agent_config').with_content(/mmsBaseUrl=https:\/\/www\.example\.com/)
          is_expected.to contain_file('mongo_agent_config').with_content(/logFile=\/var\/tmp\/nothing\.log/)
          is_expected.to contain_file('mongo_agent_config').with_content(/mmsConfigBackup=\/var\/lib\/nothing\.json/)
          is_expected.to contain_file('mongo_agent_config').with_content(/logLevel=DEBUG/)
          is_expected.to contain_file('mongo_agent_config').with_content(/maxLogFiles=99/)
          is_expected.to contain_file('mongo_agent_config').with_content(/maxLogFileSize=123456/)
          is_expected.to contain_file('mongo_agent_config').with_content(/httpProxy=/)

          is_expected.to contain_service('mongodb-mms-automation-agent').with(
            ensure: 'running',
            enable: true,
            require: 'File[mongo_agent_config]',
          )
        }
      end
    end
  end
end
