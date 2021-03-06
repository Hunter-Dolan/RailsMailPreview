require File.dirname(__FILE__) + "/test_helper.rb"

describe Message do
  before do
    FBDatabaseBase.send(:initialize)
    path = "#{CURRENT_PATH}/fixtures/html_text_attachment.txt"
    content = File.open(path) {|f| f.read }
    @mail = Mail.new(content)
  end

  describe :setMessage do
    it 'has attachments' do
     message = Message.new
     message.setMessage(@mail)
     message.attachments.size.must_equal 1
    end
  end

  describe :save do
    it 'will save and return the inserted id' do
     message = Message.new
     message.setMessage(@mail)
     message.save
     message.id.to_s.must_match /[0-9]+/
    end

    it 'returns true' do
      message = Message.new
      message.setMessage(@mail)
      message.save.must_equal true
    end
  end

  describe :all do
    it "returns results" do
      results = Message.all
      results.first.class.name.must_equal "Message"
    end
  end

  describe :first do
    it "returns the first record" do
      result = Message.first
      result.class.name.must_equal "Message"
    end
  end

  describe :find_by_id do
    it "returns record for id" do
      result = Message.find_by_id(2)
      result.id.must_equal 2
    end
  end

end
