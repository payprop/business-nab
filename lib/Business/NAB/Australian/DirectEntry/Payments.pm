package Business::NAB::Australian::DirectEntry::Payments;

=head1 NAME

Business::NAB::Australian::DirectEntry::Payments

=head1 SYNOPSIS

    use Business::NAB::Australian::DirectEntry::Payments;

    # parse:
    my $Payments = Business::NAB::Australian::DirectEntry::Payments
        ->new_from_file( $file_path );

    foreach my $DetailRecord ( $Payments->detail_record->@* ) {
        ...
    }

    # build:
    my $Payments = Business::NAB::Australian::DirectEntry::Payments->new;

    $Payments->add_descriptive_record(
        .. # Business::NAB:: ... DescriptiveRecord object
    );

    $Payments->add_detail_record(
        .. # Business::NAB:: ... DetailRecord object
    ) for ( @payments );

    # optional:
    $Payments->add_total_record(
        .. # Business::NAB:: ... TotalRecord object
    );

    $Payments->to_file(
        $file_path,
        $bsb_number, # if TotalRecord is not set
        $separator, # defaults to "\r\n"
    );

=head1 DESCRIPTION

Class for building/parsing a "Australian Direct Entry Payments" file

=cut

use strict;
use warnings;
use feature qw/ signatures /;
use autodie qw/ :all /;
use Carp qw/ croak /;

use Moose;
use Moose::Util::TypeConstraints;
no warnings qw/ experimental::signatures /;

use Module::Load;
use Mojo::Util qw/ decamelize /;
use List::Util qw/ sum /;

# we have long namespaces and use them multiple times so have
# normalised them out into the $parent and @subclasses below
my $parent = 'Business::NAB::Australian::DirectEntry::Payments';

my @subclasses = ( qw/
    DescriptiveRecord
    DetailRecord
    TotalRecord
/ );

my $i = 1;

=head1 ATTRIBUTES

All attributes are ArrayRef[Obj] where Obj are of the Business::NAB::Australian::DirectEntry::Payments::* namespace:

    DescriptiveRecord
    DetailRecord
    TotalRecord

Convenience methods are available for trivial addition of new elements
to the arrays:

    $Payments->add_descriptive_record( $DescriptiveRecord );
    $Payments->add_detail_record( $DetailRecord );
    $Payments->add_total_record( $TotalRecord );

=over

=item descriptive_record (ArrayRef[Obj])

=item detail_record (ArrayRef[Obj])

=item total_record (ArrayRef[Obj])

=back

=cut

foreach my $record_type ( @subclasses ) {

    load $parent . "::$record_type";

    my $attr = decamelize( $record_type );
    my $class = "${parent}::$record_type";

    subtype $record_type
        => as "ArrayRef[$class]";

    coerce $record_type
        => from "ArrayRef[HashRef|$class]"
        => via {
            # when a new thing is pushed onto the array we need to coerce
            # it from a HashRef to the instance of the class, but if it's
            # already an instance of the class then pass it straight through
            my @objects = map {
                ref $_ eq $class
                    ? $_
                    : $class->new( $_ )
            } @{$_};

            [ @objects ];
        }
        => from "ArrayRef[Any]"
        => via {
            [ $class->new( $_->@* ) ]
        }
    ;

    has $attr => (
        traits  => [ 'Array' ],
        is      => 'rw',
        isa     => $record_type,
        coerce  => 1,
        default => sub { [] },
        handles => {
            "add_${attr}" => 'push',
        },
    );
}

=head1 METHODS

=head2 new_from_file

Returns a new instance of the class with attributes populated from
the result of parsing the passed file

    my $Payments = Business::NAB::Australian::DirectEntry::Payments
        ->new_from_file( $file_path );

=cut

sub new_from_file ( $class,$file ) {

    open( my $fh,'<',$file );

    my %sub_class_map = (
        0 => 'DescriptiveRecord',
        1 => 'DetailRecord',
        7 => 'TotalRecord',
    );

    my $self = $class->new;

    while ( my $line = <$fh> ) {

        my $type      = substr( $line,0,1 );
        my $sub_class = $sub_class_map{ $type };
        my $attr      = decamelize( $sub_class );
        my $push      = "add_${attr}";

        $sub_class || carp( "Unrecognised record type ($type) at line $." );
        $sub_class = "${parent}::${sub_class}";

        my $Instance = $sub_class->new_from_record( $line );

        $self->$push( $Instance );
    }

    return $self;
}

=head2 to_record

Writes the file content to the passed file path:

    $Payments->to_file(
        $file_path,
        $bsb_number, # if TotalRecord is not set, defaults to 999-999
        $separator, # defaults to "\r\n"
    );

=cut

sub to_file (
    $self,
    $file,
    $bsb_number = undef,
    $sep = "\r\n"
) {

    open( my $fh,'>',$file );

    print $fh $self->descriptive_record->[0]->to_record . $sep;
    print $fh $_->to_record . $sep foreach $self->detail_record->@*;

    if ( my $TotalRecord = $self->total_record->[0] ) {
        print $fh $TotalRecord->to_record . $sep;
    } else {
        croak( "BSB number is required if total_record is not set" )
            if ! $bsb_number;

        my $record_count = scalar( $self->detail_record->@* );

        # FIXME: "should be all zeros" - really? not the net of credit - debit?
        my $net_total = 0;

        my $credit_total = sum map { $_->amount }
            grep { $_->is_credit } $self->detail_record->@*;
        my $debit_total = sum map { $_->amount }
            grep { $_->is_debit } $self->detail_record->@*;

        my $TotalRecord = Business::NAB::Australian::DirectEntry::Payments::TotalRecord->new(
            bsb_number => $bsb_number,
            net_total_amount => $net_total,
            credit_total_amount => $credit_total,
            debit_total_amount => $debit_total,
            record_count => $record_count,
        );

        print $fh $TotalRecord->to_record . $sep;
    }

    close( $fh );

    return;
}

=head1 SEE ALSO

L<Business::NAB::Australian::DirectEntry::Payments::DescriptiveRecord>

L<Business::NAB::Australian::DirectEntry::Payments::DetailRecord>

L<Business::NAB::Australian::DirectEntry::Payments::TotalRecord>

=cut

__PACKAGE__->meta->make_immutable;
