require 'test_helper'

class QuestionTest < ActiveSupport::TestCase
  def setup
  	@simple = questions(:simple_eng101)
  	@fill = questions(:fill_eng101)
  	@pick_2_fill = questions(:pick_2_fill_eng101)
  	@pick_one = questions(:pick_one_stat101)
  	@pick_many = questions(:pick_many_stat101)
  	@match = questions(:match_stat101)
  	@sort = questions(:sort_stat101)
  end

  test "with valid fixtures" do
    puts "\n\n\n#{@simple.banks.map {|t| t.name}}\n\n\n"
    @simple.valid?
    puts @simple.errors.full_messages
  	assert @simple.valid?
    puts @simple.errors.full_messages
  	assert @fill.valid?
  	assert @pick_2_fill_question.valid?
  	assert @pick_one.valid?
  	assert @pick_many.valid?
  	assert @mat.valid?
  	assert @sort.valid?
  end

  test "invalid without an question" do
  	@simple.question = nil
    assert_not @simple.valid?
  end
  
  test "invalid without a kind" do
    @fill.kind = nil
    assert_not @fill.valid?
  end
  
  test "valid without a hint" do
    @fill.hint = nil
    assert @fill.valid?
  end
  
  test "valid without an explanation" do
    @fill.explanation = nil
    assert @fill.valid?
  end
  
  test "invalid if it's a simple and answer is nil" do
  	@simple.options.destroy_all
    assert_not @simple.valid?
  end
  
  test "invalid if it's a simple with more that one answer" do
  	@simple.options << options(:simple_1_eng101)
    assert_not @simple.valid?
  end
  
  test "invalid if it's a fill and has no choice" do
    @fill.options.destroy_all
    assert_not @fill.valid?
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
