package Perltris::Renderer;

use strict;
use warnings FATAL => 'all';
use v5.14;

use Time::HiRes qw(time);
use Tk;

use constant {
    NONE   => 0,
    YELLOW => 1,
    BLUE   => 2,
    RED    => 3,
    GREEN  => 4,
    ORANGE => 5,
    PINK   => 6,
    PURPLE => 7,
    BLACK  => 8,
};

use constant {
    WINDOW_WIDTH  => 250,
    WINDOW_HEIGHT => 500
};

use constant {
    BLOCK_WIDTH => WINDOW_WIDTH / 10,
};

use constant {
    TOP_PADDING => BLOCK_WIDTH * 4,
};

sub init {
    my ($board, $handle_update, $handle_key_press) = @_;

    my $window = Tk::MainWindow->new(-background => get_color(BLACK));

    $window->title('perltris');
    $window->geometry(WINDOW_WIDTH . 'x' . WINDOW_HEIGHT);

    my $canvas = $window->Canvas;

    $window->bind('<KeyPress>' => $handle_key_press);

    $canvas->pack(-expand => 1, -fill => 'both');
    $canvas->after(0, sub {
        update($canvas, $board, $handle_update)
    });
    $canvas->configure(-background => '#222');
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
        PURPLE, 'purple',
        BLACK, 'black'
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

    my $x1 = $x * BLOCK_WIDTH;
    my $y1 = $y * BLOCK_WIDTH - TOP_PADDING;

    my $x2 = $x * BLOCK_WIDTH + BLOCK_WIDTH;
    my $y2 = $y * BLOCK_WIDTH + BLOCK_WIDTH - TOP_PADDING;

    $canvas->createRectangle(
        ($x1, $y1, $x2, $y2),
        -outline => $color,
        -fill => $color
    );
}

1;