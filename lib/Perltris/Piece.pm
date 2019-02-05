package Perltris::Piece;

use strict;
use warnings FATAL => 'all';
use v5.14;

use Storable qw(dclone);

use Perltris::Renderer;

use List::Util qw(min max);

# Individual piece prototypes are modeled as a list of pairs indicating the relative location of each 'block'
# by an offset from rotation origin (0, 0) of the piece.
use constant {
    _PIECE_O => {
        pairs  => [
            [ 0, 0 ],
            [ 1, 0 ],
            [ 1, 1 ],
            [ 0, 1 ],
        ],
        color  => Perltris::Renderer::YELLOW,
    },
    _PIECE_I => {
        pairs => [
            [ 0, -1 ],
            [ 0,  0 ],
            [ 0,  1 ],
            [ 0,  2 ],
        ],
        color => Perltris::Renderer::BLUE,
    },
    _PIECE_L => {
        pairs     => [
            [ 0, -1 ],
            [ 0,  0 ],
            [ 0,  1 ],
            [ 1,  1 ],
        ],
        color => Perltris::Renderer::RED,
    },
    _PIECE_J => {
        pairs     => [
            [ 1, -1 ],
            [ 1,  0 ],
            [ 1,  1 ],
            [ 0,  1 ],
        ],
        color => Perltris::Renderer::GREEN,
    },
    _PIECE_S => {
        pairs => [
            [  0, 0 ],
            [  1, 0 ],
            [  0, 1 ],
            [ -1, 1 ],
        ],
        color => Perltris::Renderer::ORANGE,
    },
    _PIECE_T => {
        pairs => [
            [ -1, 0 ],
            [  0, 0 ],
            [  1, 0 ],
            [  0, 1 ],
        ],
        color => Perltris::Renderer::PINK,
    },
    _PIECE_Z => {
        pairs => [
            [ -1,  0 ],
            [  0,  0 ],
            [  0,  1 ],
            [  1,  1 ],
        ],
        color => Perltris::Renderer::PURPLE,
    }
};

my @_PIECES = (_PIECE_I, _PIECE_J, _PIECE_L, _PIECE_O, _PIECE_S, _PIECE_T, _PIECE_Z);

sub abs_pairs {
    # Returns the pairs, accounting for $dx, $dy, and $rotation transformations.
    my $self = shift;
    my $abs_pairs = dclone($self->{pairs});

    # Apply our rotations first.
    for (my $i = 0; $i < $self->{rotation}; ++$i) {
        my $pairs = $abs_pairs;
        # Rotate about the current origin.
        for my $pair (@{$pairs}) {
            @$pair = (-$pair->[1], $pair->[0]);
        }
    }

    # Apply delta displacements.
    for my $pair (@$abs_pairs) {
        $pair->[0] += $self->{dx};
        $pair->[1] += $self->{dy};
    }

    return $abs_pairs;
}

sub new {
    my ($piece) = @_;

    if (!$piece) { # Assume we want an empty piece if we don't receive a list of pairs.
        @$piece = ();
    }

    $piece->{dx} = 4;
    $piece->{dy} = 1;
    $piece->{rotation} = 0;

    bless($piece, 'Perltris::Piece');

    # Clone so we don't touch our constant references above if we're passed one in during construction.
    $piece->clone();
}

sub random {
    new($_PIECES[rand(scalar @_PIECES)]);
}

sub contains {
    # Returns `1` if this piece contains a block at (`$x`, `$y`), otherwise `0`.
    my ($self, $x, $y) = @_;

    for my $pair (@{$self->abs_pairs()}) {
        my ($_x, $_y) = @$pair;
        return 1 if $x == $_x && $y == $_y;
    }

    0;
}

sub clone {
    # Clone a piece with optional deltas `$dx`, `$dy`, and `$rotation`.
    my ($self, $dx, $dy, $rotation) = @_;

    # Default values if undefined.
    $dx //= 0;
    $dy //= 0;
    $rotation //= 0;

    my $clone = dclone($self);

    $clone->{dx} += $dx;
    $clone->{dy} += $dy;
    $clone->{rotation} = ($clone->{rotation} + $rotation) % 4;

    $clone;
}

1;