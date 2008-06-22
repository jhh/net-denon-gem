# Look in the tasks/setup.rb file for the various options that can be
# configured in this Rakefile. The .rake files in the tasks directory
# are where the options are used.

load 'tasks/setup.rb'

ensure_in_path 'lib'
require 'net/denon'

task :default => 'spec:run'

PROJ.name = 'net-denon-gem'
PROJ.authors = 'Jeff Hutchison'
PROJ.email = 'hutchison.jeff@gmail.com'
PROJ.url = 'http://github.com/jhh/net-denon-gem/tree/master'
PROJ.rubyforge.name = 'net-denon-gem'

PROJ.spec.opts << '--color'

# EOF
