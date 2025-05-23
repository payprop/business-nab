package Business::NAB::FileContainer;

# undocument abstract class

use strict;
use warnings;
use feature qw/ signatures /;
use autodie qw/ :all /;
use Carp    qw/ croak /;

use Moose;
use Moose::Util::TypeConstraints;
no warnings qw/ experimental::signatures /;

use Module::Load;
use Mojo::Util qw/ decamelize /;

sub load_attributes (
    $self,
    $parent,
    @subclasses,
) {
    foreach my $record_type ( @subclasses ) {

        load( $parent . "::$record_type" );

        my $attr  = decamelize( $record_type );
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
            } @{ $_ };

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
}

sub new_from_file (
    $self,
    $parent,
    $file,
    $sub_class_map,
    $split_char = undef,
) {
    open( my $fh, '<', $file );

    while ( my $line = <$fh> ) {

        $line =~ s/\r\n$//;

        my ( $type ) = $split_char
            ? ( split( $split_char, $line ) )[ 0 ]
            : substr( $line, 0, 1 );

        next if !length( $type );

        my $sub_class = $sub_class_map->{ $type };
        my $attr      = decamelize( $sub_class );
        my $push      = "add_${attr}";

        $sub_class || croak( "Unrecognised record type ($type) at line $." );
        $sub_class = "${parent}::${sub_class}";

        my $Instance = $sub_class->new_from_record( $line );

        $self->$push( $Instance );
    }

    return $self;
}

1;
