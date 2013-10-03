# Aviator Session Pool

Experimental library for managing [Aviator](http://aviator.github.io/www) sessions.

[![Build Status](https://travis-ci.org/aviator/session_pool.png?branch=master)](https://travis-ci.org/aviator/session_pool)
[![Coverage Status](https://coveralls.io/repos/aviator/session_pool/badge.png)](https://coveralls.io/r/aviator/session_pool)

```ruby
require 'aviator'
require 'aviator/session_pool'

Aviator::SessionPool.configure(
  config_file: 'path/to/aviator.yml',
  environment: :production,
  log_file:    'path/to/aviator.log',
  redis_host:  'localhost', 
  redis_port:   6785
)


#==================
# LOGIN CONTROLLER
#==================

# Create an unscoped session
Aviator::SessionPool.get_or_create(session[:session_id]) do |creds|
  creds.username = username
  creds.password = password
end


# Moments pass...

# Now the user is requesting access to a specific project/tenant

#===============================
# IN A CONTROLLER BEFORE_FILTER
#===============================

# Attempt to get the unscoped session which is an indicator that
# the user has been previously authenticated.
#
# When getting a session from the pool, SessionPool calls the
# object's validate method. If that method returns false, then
# SessionPool will return nil. If there is no session with the
# given key, SessionPool will also return nil.
unless unscoped = Aviator::SessionPool.get(session[:session_id])
  # This means the user is not yet authenticated or
  # her session with OpenStack has expired. Do the ff:
  #   - Log out user
  #   - Redirect user to login page
end


#=====================================
# IN ANOTHER CONTROLLER BEFORE_FILTER
#=====================================

# Since user is asking for resources for a specific tenant, let's
# get a session scoped to that tenant.
Aviator::SessionPool.get_or_create(session[:session_id] + tenant_name.underscore) do |creds|
  creds.token_id = unscoped[:auth_info][:access][:token][:id]
  creds.tenant_name = tenant_name
end

# scoped will have to be shared between the controller and
# whichever model or object will need to use it. 
Aviator::SessionPool.set_current(session[:session_id] + tenant_name.underscore)


#=========================
# IN SOME MODEL OR OBJECT
#=========================

# Use current session like any other Aviator session. If set_current was not
# called prior to this, get_current will raise a CurrentSessionNotDefinedError
#
# WARNING: Since get_current uses a class instance variable, it will contain
# a value between http requests whether set_current was called or not for as long
# as it was called at least once.
Aviator::SessionPool.get_current.compute_service.request(:list_servers)



# Maintaining an admin session

# Authentication will use credentials in the config file since
# a block is not provided in this call.
admin = Aviator::SessionPool.get_or_create('admin')

#=========================
# IN SOME MODEL OR OBJECT
#=========================

# Use the admin session
Aviator::SessionPool.get_or_create('admin').identity_service.request(:list_tenants, endpoint_type: :admin)



#=========================
# HOW get_or_create WORKS
#=========================

def get_or_create(session_id, &block)
  # If session is invalid or does not exist, self[] will return nil
  unless session = self[session_id]
    session = Session.new(config_file: config_file, environment: environment, log_file: log_file_path)

    session.authenticate &block
 
    self[session_id] = session
  end
  
  session
end
```
