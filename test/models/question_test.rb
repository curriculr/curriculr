require 'test_helper'

class QuestionTest < ActiveSupport::TestCase
  def setup
  	@fill_one = questions(:fill_one_eng101)
  	@fill_many = questions(:fill_many_eng101)
  	@pick_2_fill = questions(:pick_2_fill_eng101)
  	@pick_one = questions(:pick_one_stat101)
  	@pick_many = questions(:pick_many_stat101)
  	@match = questions(:match_stat101)
  	@sort = questions(:sort_stat101)
  end

  test "with valid fixtures" do
  	assert @fill_one.valid?
  	assert @fill_many.valid?
    assert @pick_2_fill.valid?
  	assert @pick_one.valid?
  	assert @pick_many.valid?
  	assert @match.valid?
  	assert @sort.valid?
  end

  test "invalid without an question" do
  	@fill_one.question = nil
    assert_not @fill_one.valid?
  end
  
  test "invalid without a kind" do
    @fill_many.kind = nil
    assert_not @fill_many.valid?
  end
  
  test "valid without a hint" do
    @fill_many.hint = nil
    assert @fill_many.valid?
  end
  
  test "valid without an explanation" do
    @fill_many.explanation = nil
    assert @fill_many.valid?
  end
  
  test "invalid if it's a fill_one and answer is nil" do
  	@fill_one.options.destroy_all
    assert_not @fill_one.valid?
  end
  
  test "invalid if it's a fill_many and has no choice" do
    @fill_many.options.destroy_all
    assert_not @fill_many.valid?
  end
  
  test "invalid if it's a pick_2_fill and has no choice" do
    @pick_2_fill.options.destroy_all
    assert_not @pick_2_fill.valid?
  end
  
  test "invalid if it's a pick_one and has no choice" do
    @pick_one.options.destroy_all
    assert_not @pick_one.valid?
  end
  
  test "invalid if it's a pick_many and has no choice" do
    @pick_many.options.destroy_all
    assert_not @pick_many.valid?
  end
  
  test "invalid if it's a match and has no choice" do
    @match.options.destroy_all
    assert_not @match.valid?
  end
  
  test "invalid if it's a sort and has no choice" do
    @sort.options.destroy_all
    assert_not @sort.valid?
  end
end
