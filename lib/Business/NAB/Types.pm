package Business::NAB::Types;

=head1 NAME

Business::NAB::Types

=head1 SYNOPSIS

    use Business::NAB::Types qw/
        add_max_string_attribute
    /;

    has [ qw/
        process_date
    / ] => (
        is       => 'ro',
        isa      => 'NAB::Type::Date',
        required => 1,
        coerce   => 1,
    );

    ...

=head1 DESCRIPTION

Package for defining type constraints for use in the Business::NAB
namespace. All types are namespaced to C<NAB::Type::*>.

=cut

use strict;
use warnings;
use feature qw/ signatures /;

use Moose::Util::TypeConstraints;
no warnings qw/ experimental::signatures /;

use DateTime::Format::DateParse;    ## no critic
use Mojo::Util qw/ decamelize /;
use Exporter::Easy (
    OK => [
        qw/
            add_max_string_attribute
            /
    ]
);

=head1 TYPES

=over

=item NAB::Type::Date

A DateTime object, this will be coerced from the string DDMMYY

=cut

class_type 'DateTime';

subtype 'NAB::Type::Date'
    => as 'DateTime';

coerce 'NAB::Type::Date'
    => from 'Str'
    => via {
    my $date_str = $_;

    return $date_str if ref( $date_str );

    my ( $dd, $mm, $yy ) = ( $date_str =~ /^(\d{2})(\d{2})(\d{2})$/ );
    my $yyyy = "20$yy";    # gyragh! Y2K never happened?
    return DateTime::Format::DateParse->parse_datetime( "$yyyy-$mm-$dd" );
    };

=item NAB::Type::StatementDate

A DateTime object, this will be coerced from the string YYMMDD

=cut

subtype 'NAB::Type::StatementDate'
    => as 'DateTime';

coerce 'NAB::Type::StatementDate'
    => from 'Str'
    => via {
    my $date_str = $_;

    return $date_str if ref( $date_str );

    my ( $yy, $mm, $dd ) = ( $date_str =~ /^(\d{2,4})(\d{2})(\d{2})$/ );
    my $yyyy = length( $yy ) == 4 ? $yy : "20$yy";    # Y2K never happened?
    return DateTime::Format::DateParse->parse_datetime( "$yyyy-$mm-$dd" );
    };

=item NAB::Type::PositiveInt

An Int greater than zero

=cut

subtype 'NAB::Type::PositiveInt'
    => as 'Int'
    => where { $_ > 0 }
=> message { "The number provided, $_, was not positive" }
;

=item NAB::Type::PositiveIntOrZero

An Int greater than or equal to zero

=cut

subtype 'NAB::Type::PositiveIntOrZero'
    => as 'Int'
    => where { $_ >= 0 }
=> message { "The number provided, $_, was not positive or zero" }
;

=item NAB::Type::BSBNumber

A Str of the form C</^\d{3}-?\d{3}$/>

=cut

subtype 'NAB::Type::BSBNumber'
    => as 'Str',
    => where { $_ =~ /^\d{3}-?\d{3}$/ }
=> message { "The BSB provided, $_, does not match \\d{3}-?\\d{3}" }
;

=item NAB::Type::AccountNumber

A Str of the form:

 * Alpha-Numeric (A-z0-9)
 * Hyphens & blanks only are valid
 * Must not contain all blanks or all zeros

And:

 * Leading zeros, which are part of an account number, must be shown
 * Edit out hyphens where account number exceeds nine characters
 * Right justified
 * Leave blank

=cut

subtype 'NAB::Type::AccountNumber'
    => as 'Str',
    => where {
    length( $_ ) < 10
        && $_ =~ /^[A-z0-9\ \-]+$/
        && $_ !~ /^(\s|0)+$/
}
=> message { "The account number provided, $_, is not valid" }
;

=item NAB::Type::Indicator

A Str of the form C</^[\ NTWXY]$/>

=cut

subtype 'NAB::Type::Indicator'
    => as 'Maybe[Str]',
    => where { $_ =~ /^[ NTWXY]$/ }
=> message { "The indicator provided, $_, does not match [ NTWXY]" }
;

=back

=head1 METHODS

=head4 add_max_string_attribute

Helper method to allow easier definition of Str types that are limited
to a particular lengths. For example:

    __PACKAGE__->add_max_string_attribute(
        'RecipientNumber[20]'
        is       => 'ro',
        required => 0,
    );

Is equivalent to:

    subtype 'NAB::Type::RecipientNumber'
        => as 'Maybe[Str]'
        => where {
            ! defined( $_ )
            or length( $_ ) <= 20
        }
        => message {
            "The string provided for recipient_number"
           . " was outside 1..20 chars"
        }
    ;

    __PACKAGE__->meta->add_attribute( 'recipient_number',
        isa       => 'NAB::Type::RecipientNumber',
        predicate => "_has_recipient_number",
        is        => 'ro',
        required  => 0,
    );

If you provide a suffix a trigger will be created to honour the requirement.
For example:

    __PACKAGE__->add_max_string_attribute(
        'reel_sequence_number[2:trim_leading_zeros]',
        ...
    );

Will make the trigger remove leading zeros whenever the attribute is set or
updated.

Current supported suffixes are:

    * trim_leading_zeros

=cut

sub add_max_string_attribute (
    $package,
    $name_spec,
    %attr_spec,
) {
    my ( $subtype_name, $max_length, $trim )
        = ( $name_spec =~ /^(\w+)\[(\d+)(:[A-z-]+)?\]$/ );
    my $attr_name = decamelize( $subtype_name );

    subtype "NAB::Type::$subtype_name"
        => as 'Maybe[Str]'
        => where {
        !defined( $_ )
            or length( $_ ) <= $max_length
    }
    => message {
        "The string provided for $attr_name"
            . " was outside 1..$max_length chars"
    }
    ;

    $package->meta->add_attribute(
        $attr_name,
        isa       => "NAB::Type::$subtype_name",
        predicate => "_has_$attr_name",

        # trim via trigger if required
        (
            $trim
            ? (
                trigger => sub {
                    my ( $self, $value, $old_value ) = @_;

                    $value =~ s/^0+// if $trim eq ':trim_leading_zeros';

                    $self->{ $attr_name } = $value;

                } )
            : ()
        ),

        %attr_spec,
    );
}

1;
