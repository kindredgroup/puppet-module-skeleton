require 'spec_helper'
require 'yaml'

describe "Puppet" do
  it "should run without errors" do
    last_run = YAML.load_file('/var/lib/puppet/state/last_run_summary.yaml')
    expect(last_run['resources']['failed']).to eq(0)
    expect(last_run['resources']['skipped']).to eq(0)
    expect(last_run['resources']['failed_to_restart']).to eq(0)
    expect(last_run['events']['failure']).to eq(0)
  end
end
