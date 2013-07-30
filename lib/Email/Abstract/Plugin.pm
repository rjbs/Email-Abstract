use strict;
use warnings;
package Email::Abstract::Plugin;
# ABSTRACT: a base class for Email::Abstract plugins

=method is_available

This method returns true if the plugin should be considered available for
registration.  Plugins that return false from this method will not be
registered when Email::Abstract is loaded.

=cut

sub is_available { 1 }

1;
