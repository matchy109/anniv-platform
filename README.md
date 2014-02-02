# Fetch Aiversary Data Script 
fetch anniv data from setting url and update data on DB

##Parameters  
This script can be set optional configuration parameters in the Configration file.

example:  
```  
  base_url => "http://www.anniv.co.jp",
  month_parameter => "month",
  day_parameter => "day",
  html_attribute => "anniv",
  log_dir => "/var/log/anniv",
  mail_to => "mail_to\@example.com",
  mail_from => "mail_from\@example.com",
  db_hostname => "db_host@example.com",
  db_port=> "3306",
  db_name => "anniv_db",
  db_user => "anniv_user",
  db_password => "anniv_user"
```
  
##How To Run  
To run this report use `perl update_anniv.pl -c your_configurations.conf`

 you need configuration file for this script and you should set following options in cofigration file.

