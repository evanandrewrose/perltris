package Renderer;

use strict;
use warnings FATAL => 'all';
use v5.14;

use Time::HiRes qw(time);
use Tk;

use constant {
    NONE => 0,
    YELLOW => 1,
    BLUE => 2,
    RED => 3,
    GREEN => 4,
    ORANGE => 5,
    PINK => 6,
    PURPLE => 7,
};

sub init {
    my ($board, $handle_update, $handle_key_press) = @_;

    my $window = Tk::MainWindow->new;
    my $canvas = $window->Canvas;

    $window->bind('<KeyPress>' => $handle_key_press);

    $canvas->pack(-expand => 1, -fill => 'both');

    $canvas->after(0, sub {
        update($canvas, $board, $handle_update)
    });
}

sub start {
    MainLoop();
}

sub get_color {
    my ($color) = @_;

    my %mapping = (
        NONE, 'black',
        YELLOW, 'yellow',
        BLUE, 'blue',
        RED, 'red',
        GREEN, 'green',
        ORANGE, 'orange',
        PINK, 'pink',
        PURPLE, 'purple'
    );

    $mapping{$color};
}

sub update {
    my ($canvas, $board, $handle_update) = @_;

    $canvas->delete('all');

    while (my ($y, $row) = each @$board) {
        while (my ($x, $color) = each @$row) {
            draw_square($canvas, $x, $y, get_color($color)) if $color;
        }
    }

    $handle_update->($board);

    $canvas->after(100, sub {
        update($canvas, $board, $handle_update)
    });
}

sub draw_square {
    my ($canvas, $x, $y, $color) = @_;

    my $x_c = $x . "c";
    my $y_c = $y . "c";

    my $x2_c = $x + 1 . 'c';
    my $y2_c = $y + 1 . 'c';

    $canvas->createRectangle(
        ($x_c, $y_c, $x2_c, $y2_c),
        -outline => $color,
        -fill => $color
    );
}

1;