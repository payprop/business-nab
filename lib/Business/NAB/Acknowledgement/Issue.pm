package Business::NAB::Acknowledgement::Issue;

=head1 NAME

Business::NAB::Acknowledgement::Issue

=head1 SYNOPSIS

    my $Issue = Business::NAB::Acknowledgement::Issue->new(
        code => "290049",
        detail => "Uploaded Interchange 60063804 for ...",
    );

=head1 DESCRIPTION

Class for NAB file acknowledgement issues. You probably don't want
to interact with this class and instead use the parent class
L<Business::NAB::Acknowledgement>.

=cut

use strict;
use warnings;

use Moose;
use Moose::Util::TypeConstraints;
no warnings qw/ experimental::signatures /;

=head1 ATTRIBUTES

=over

=item code (Str, required)

=item detail (Str, required)

=back

=cut

has [ qw/ code detail / ] => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

=head1 SEE ALSO

L<Business::NAB::Acknowledgement>

=cut

__PACKAGE__->meta->make_immutable;
