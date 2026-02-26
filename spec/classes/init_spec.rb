# frozen_string_literal: true

require 'spec_helper'
describe 'mongodb_automation_agent' do
  context 'with defaults for all parameters' do
    it { is_expected.to contain_class('mongodb_automation_agent') }
  end
end
