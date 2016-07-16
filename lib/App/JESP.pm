package App::JESP;

use Moose;

=head1 NAME

App::JESP - Just Enough SQL Patches

=cut

=head1 SYNOPSIS

Use the command line utility:

  jesp

Or use from your own program:

  my $jesp = App::JESP->new({ ... });

=cut

=head1 DEVELOPMENT

=for html <a href="https://travis-ci.org/jeteve/App-JESP"><img src="https://travis-ci.org/jeteve/App-JESP.svg?branch=master"></a>

=head1 COPYRIGHT

This software is released under the Artistic Licence by Jerome Eteve. Copyright 2016.
A copy of this licence is enclosed in this package.

=cut

__PACKAGE__->meta->make_immutable();
1;
