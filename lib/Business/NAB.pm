package Business::NAB;

=head1 NAME

Business::NAB

=head1 DESCRIPTION

Business::NAB is the top level namespace for the various modules
that are used to parse/create the file formats used for interchange
with NAB.

This module doesn't do anything, rather it serves to link to the
modules that you want to use.

=head1 L<Business::NAB::Types>

Package for defining type constraints for use in the Business::NAB
namespace. All types are namespaced to "NAB::Type::*".

=head1 L<Business::NAB::BPAY::Payments>

Class for parsing / creating a NAB BPAY batch payments file

=head1 L<Business::NAB::Australian::DirectEntry::Payments>

Class for building/parsing a "Australian Direct Entry Payments" file

=head1 L<Business::NAB::AccountInformation::File>

Class for parsing a NAB "Account Information File (NAI/BAI2)" file

=head1 L<Business::NAB::Acknowledgement>

Class for parsing NAB file acknowledgements, which are XML files

=cut

1;
