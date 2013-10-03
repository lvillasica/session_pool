guard 'minitest' do
  watch(%r|^lib/aviator/session_pool\.rb|)            { "test" }
  watch(%r|^test/test_helper\.rb|)       { "test" }
  watch(%r|^lib/aviator/(.*)\.rb|)       { |m| "test/aviator/#{m[1]}_test.rb" }
  watch(%r|^test/aviator/.*_test\.rb|)   # Run the matched file
end
