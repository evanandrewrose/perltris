use strict;
use warnings FATAL => 'all';
use v5.14;

use Piece qw(new);
use Renderer;

use Time::HiRes qw(time);
use List::Util qw(all);

use constant {
    UPDATE_TIME_S => .5, # Length of time between each updated frame in seconds.
};

use constant {
    LEFT => "Left",
    RIGHT => "Right",
    UP => "Up",
    DOWN => "Down",
    SPACE => "space",
};

use constant {
    BOARD_WIDTH => 10,
    BOARD_HEIGHT => 20,
};

my $piece = Piece::random();

my @board = map [
    map(0, 0..BOARD_WIDTH - 1)
], 0..BOARD_HEIGHT - 1;

sub main() {
    Renderer::init(\@board, \&handle_update, \&handle_key_press);
    Renderer::start();
}

sub handle_update {
    state $last_updated = 0;

    if (time() - $last_updated > UPDATE_TIME_S) {
        $last_updated = time();

        # Try to move the current piece down. If it fails, we've hit the bottom.
        if (not move_piece(0, 1)) {
            handle_piece_landed();
        }
    }
}

sub valid_piece_location {
    # Returns 1 if the piece location of `$new_piece` is valid.
    my ($new_piece) = @_;

    for my $pair (@{$new_piece->abs_pairs()}) {
        my ($x, $y) = @$pair;

        # Check for boundaries.
        return 0 if ($y >= BOARD_HEIGHT || $y < 0 || $x < 0 || $x >= BOARD_WIDTH);

        # Check for collision (only against piece that aren't the current piece!).
        return 0 if $board[$y]->[$x] and !$piece->contains($x, $y);
    }

    return 1;
}

sub move_piece {
    # Returns `1` if move is successful, otherwise `0`.
    my ($dx, $dy, $rotate) = @_;

    my $new_piece = $piece->clone($dx, $dy, $rotate); # Holds the possible new piece data.

    return 0 if not valid_piece_location($new_piece);

    # Clear the location where the piece currently exists.
    set_piece_board_data($piece, \@board, Renderer::NONE);

    $piece = $new_piece;

    # Redraw the piece in the new location.
    set_piece_board_data($piece, \@board, $piece->{color});

    1;
}

sub shift_rows_above {
    my ($y) = @_;

    # This function moves all pieces at row < $y down one row (helper for clearing).
    for (my $yi = $y; $yi > 1; $yi--) {
        @{$board[$yi]} = @{$board[$yi - 1]};
    }
}

sub clear_complete_rows {
    my ($board) = @_;

    # Work backwards from the bottom, checking for empty rows.
    for (my $y = BOARD_HEIGHT - 1; $y > 0; $y--) {
        # If we find a complete row, clear it and check it again.
        if (all { $_ } @{$board->[$y]}) {
            shift_rows_above($y);
            redo;
        }
    }
}

sub set_piece_board_data {
    my ($piece, $board, $color) = @_;

    for my $pair (@{$piece->abs_pairs()}) {
        my ($x, $y) = @$pair;
        $board->[$y]->[$x] = $color;
    }
}

sub handle_piece_landed() {
    # Clear rows if applicable.
    clear_complete_rows(\@board);

    # TODO: Check if player lost.

    # Create a new piece to play with.
    $piece = Piece::random();
}

sub handle_key_press {
    my $event = shift->XEvent;
    my $key = $event->K;

    handle_left()  if ($key eq LEFT );
    handle_right() if ($key eq RIGHT);
    handle_up()    if ($key eq UP   );
    handle_down()  if ($key eq DOWN );
    handle_space() if ($key eq SPACE);
}

sub handle_left {
    move_piece(-1, 0);
}

sub handle_right {
    move_piece(1, 0);
}

sub handle_down {
    if (not move_piece(0, 1)) {
        handle_piece_landed();
    }
}

sub handle_up {
    move_piece(0, 0, 1);
}

sub handle_space {
    for (;;) {
        last if !move_piece(0, 1);
    }

    handle_piece_landed();
}

main();
