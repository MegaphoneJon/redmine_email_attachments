require 'htmlentities'
coder = HTMLEntities.new
FIND_ATTACHMENT_SRC_PATTERN = /(<a href=")((?:#{Setting.protocol + "://[^/]+" + Redmine::Utils.relative_url_root})[^"]+)("[^>]*>)/
NEW_FILE_PATTERN = /(<a href=")((?:#{Setting.protocol + "://[^/]+" + Redmine::Utils.relative_url_root})[^"]+)"[^>]*>(.*)<\/a> added/

Redmine::Plugin.register :redmine_email_attachments do
  name 'Redmine Email Attachments plugin'
  author 'Jon Goldberg'
  description 'Send attachments directly in notification emails.'
  version '0.2.0'
  url 'http://github.com/MegaphoneJon/redmine_email_attachments'
  author_url 'http://megaphonetech.com'
end
