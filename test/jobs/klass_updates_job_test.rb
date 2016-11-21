require 'test_helper'

class KlassUpdatesJobTest < ActiveJob::TestCase
  test "the truth" do
     KlassUpdatesJob.perform_now(false)
    assert true
  end
end
