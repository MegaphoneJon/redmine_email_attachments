# Redmine Email Images

The plugin address this issue: http://www.redmine.org/issues/3760. 

## Description

Email clients are not logged in and can't load images in email notifications
from redmine. You can either allow downloading attachments for anonymous
users or include images as attachments in email. This plugin uses second 
approach.

## Installation

To install the plugin clone the repo

```
cd /path/to/redmine/
git clone https://github.com/MegaphoneJon/redmine_email_attachments.git
bundle install
```

## Compatibility

The latest version of this plugin is only tested with Redmine 5.

## Areas for improvement
* Combining this with [redmine_email_images](https://www.redmine.org/plugins/redmine_email_images) causes the attachment to be added twice.  It appears fine but the email is larger.
* Ideally we wouldn't hard-code the images directory to `/usr/src/redmine/files`.  Patches welcome.
