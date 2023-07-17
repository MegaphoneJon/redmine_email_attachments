require 'pathname'

class AttachmentPatch
  def self.delivering_email(message)
    text_part = message.text_part
    html_part = message.html_part
    
    # look for the "File x added" text and get an array of the filenames.
    if html_part
      new_files = Array.new
      html_part.body.to_s.gsub(NEW_FILE_PATTERN) do
        new_files << $3
      end
    end

    if new_files.any?
      # change the MIME type from "multipart/alternative" to "multipart/mixed".
      original_mail_part = Mail::Part.new
      original_mail_part.content_type = 'multipart/alternative'
      original_mail_part.add_part text_part
      original_mail_part.add_part html_part
      message.parts.clear
      message.add_part original_mail_part
      message.content_type = message.content_type.sub(/alternative/, 'mixed')
      Rails.logger.info 'content_type hello'
      Rails.logger.info message.content_type
      attachment_hash = Hash.new
      html_part.body = html_part.body.to_s.gsub(/<body[^>]*>/, "\\0 ")
      html_part.body.to_s.gsub(FIND_ATTACHMENT_SRC_PATTERN) do
        image_url = $2
        # is there an attachment whose name matches this attachment?
        attachment_object = Attachment.where(:id => Pathname.new(image_url).dirname.basename.to_s).first
        if attachment_object
          # is this attachment new?
          image_name = attachment_object.filename
          if new_files.include? image_name
            # FIXME: Surely there's a way to get the file directory without hard-coding it.
            # FIXME: If you add file_a to the issue, then add file_a in a separate comment, both show as attachments.
            image_path = '/usr/src/redmine/files/' + attachment_object.disk_directory + '/' + attachment_object.disk_filename
            attachment_hash[image_name] = File.read(image_path)
          end
        end

      end

     attachment_hash.each do |image_name, image_path| 
       message.attachments[image_name] = image_path
     end
    end
  end
end

ActionMailer::Base.register_interceptor(AttachmentPatch)

