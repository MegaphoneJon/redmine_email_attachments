require 'minitest/autorun'
require 'tmpdir'

module ActionMailer
  class Base
    def self.register_interceptor(_interceptor); end
  end
end
module Rails
  def self.logger = Object.new.tap { |logger| def logger.info(_message); end }
end
module Mail
  class Part
    attr_accessor :content_type
    def add_part(_part); end
  end
end
NEW_FILE_PATTERN = /(<a href=")([^\"]+)"[^>]*>(.*)<\/a> added/
FIND_ATTACHMENT_SRC_PATTERN = /(<a href=")([^\"]+)("[^>]*>)/

class Attachment
  class << self
    attr_accessor :record
    def where(id:) = id == '1' ? [record] : []
  end
end
Part = Struct.new(:body)
Message = Struct.new(:text_part, :html_part, :parts, :content_type, :attachments) do
  def add_part(part) = parts << part
end
Record = Struct.new(:filename, :diskfile)
require_relative '../lib/attachment_patch'

class AttachmentStorageTest < Minitest::Test
  def test_uses_configured_diskfile_and_preserves_binary_bytes
    Dir.mktmpdir do |dir|
      path = File.join(dir, 'configured-storage.bin')
      content = "\xFF\x00\xFE".b
      File.binwrite(path, content)
      Attachment.record = Record.new('binary.bin', path)
      html = '<body>中文通知 <a href="http://example.invalid/attachments/download/1/binary.bin">binary.bin</a> added</body>'
      message = Message.new(Part.new('plain'), Part.new(html), [], 'multipart/alternative', {})
      AttachmentPatch.delivering_email(message)
      assert_equal content, message.attachments['binary.bin']
      assert_equal Encoding::BINARY, message.attachments['binary.bin'].encoding
      assert_equal 'multipart/mixed', message.content_type
    end
  end

  def test_plain_text_messages_are_left_unchanged
    message = Message.new(nil, nil, [], 'text/plain', {})
    AttachmentPatch.delivering_email(message)
    assert_empty message.attachments
    assert_equal 'text/plain', message.content_type
  end
end
