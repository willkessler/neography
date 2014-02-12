guard :rspec do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^spec/support/(.+)\.rb$}) { 'spec' }
  watch('spec/spec_helper.rb') { 'spec' }

  watch(%r{^lib/(.+)\.rb$}) do |m|
    f = "spec/#{m[1]}_spec.rb"
    File.exist?(f) ? f : 'spec'
  end
end
