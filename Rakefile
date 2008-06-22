# Look in the tasks/setup.rb file for the various options that can be
# configured in this Rakefile. The .rake files in the tasks directory
# are where the options are used.

load 'tasks/setup.rb'

ensure_in_path 'lib'
require 'net/denon'
require 'find'

task :default => 'test:run'

PROJ.name = 'net-denon-gem'
PROJ.summary = 'Provides DENON AVR control protocol client functionality.'
PROJ.authors = 'Jeff Hutchison'
PROJ.email = 'hutchison.jeff@gmail.com'
PROJ.url = 'http://github.com/jhh/net-denon-gem/tree/master'
PROJ.rubyforge.name = 'net-denon-gem'

PROJ.spec.opts << '--color'

PROJ.rcov.opts << '-Ilib:test -x rcov.rb'

PROJ.exclude << %w(\.DS_Store* .gitignore debug.txt ^spec ^test ^tasks)

PROJ.gem.files = manifest_files

# EOF
