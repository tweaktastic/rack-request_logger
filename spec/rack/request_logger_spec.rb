require 'spec_helper'

describe Rack::RequestLogger do
  it 'has a version number' do
    expect(Rack::RequestLogger::VERSION).not_to be nil
  end

  it 'does something useful' do
    expect(false).to eq(true)
  end
end
