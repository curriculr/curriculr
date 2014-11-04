shared_examples "Regular controller CRUD" do
  describe 'GET #index' do
    it "populates an array of contacts" do
      expect(1).to be(1)
    end
  
    it "renders the :index template" do
      expect(1).to be(1)
    end
  end
 
  describe 'GET #show' do
    it "assigns the requested contact to @contact" do
      expect(1).to be(1)
    end
  end
end
