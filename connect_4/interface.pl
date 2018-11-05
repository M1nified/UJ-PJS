#!/usr/bin/perl

use IO::Select;

package Player;

sub new {
   my $class = shift;
   my $self = {
       _type => shift,
   };
   print "Player type: ", $self->{_type}, "\n";
   bless $self, $class;
   return $self;
}

sub cout {
    my( $self, $msg ) = @_;
    if ($self->{_type} eq 'human') {
        print $msg;
    }
}

sub inform_board {
    my ($self, $board) = @_;
    if ($self->{_type} eq 'human') {
        my @bdisp = split(/:/, $board);
        my $bx = $bdisp[1];
        my $by = $bdisp[2];
        my $bdisp = $bdisp[3];
        $bdisp =~ s/,,/,_,/g;
        $bdisp =~ s/,,/,_,/g;
        $bdisp =~ s/^,/_,/g;
        $bdisp =~ s/,$//g;
        my @bdisp = split(/,/, $bdisp);
        my $blen = $bx * $by;
        for my $i (0..$blen) {
            if ( $i % $bx == 0) {
                print "\n";
            }
            print $bdisp[$i], "|";
        }
        print "\n";
    }
}

sub inform_win {
    my ($self, $winner) = @_;
    if ($self->{_type} eq 'human') {
        print "The winner is: $winner \n";
    }
}

sub getCol9 {
    my( $self ) = @_;
    # print "getCol9 ", $self->{_type}, "\n";
    if ($self->{_type} eq 'human') {
        # print "getCol9 human in \n";
        if ($BSD_STYLE) {
            system "stty cbreak </dev/tty >/dev/tty 2>&1";
        }
        else {
            system "stty", '-icanon', 'eol', "\001";
        }
        my $col = getc(STDIN);
        if ($BSD_STYLE) {
            system "stty -cbreak </dev/tty >/dev/tty 2>&1";
        }
        else {
            system 'stty', 'icanon', 'eol', '^@'; # ASCII NUL
        }
        print "\n";
        return $col;
    }
}

package Processor;

sub new {
   my $class = shift;
   my $self = {};
   bless $self, $class;
   return $self;
}

package Inter;

my $player_a = new Player('human');
my $player_b = new Player('human');

sub ProcessLine {
    my $line = $_[0];
    my @info = split(/\:/,$line);
    my $name = $info[0];
    if ($name eq "board") {
        print 'bsize', $info[1], $info[2], "\n";
    } elsif ($name eq "won_by") {
        
    } elsif ($name eq "current_player") {
        print $line, "\n";
        my $player = $info[1];
        my $char;
        if ($player eq "a") {
            print "trying to get move for ", $player, " \n";
            $char = $player_a->getCol9();
        } elsif ($player eq "b") {
            print "trying to get move for ", $player, " \n";
            $char = $player_b->getCol9();
        } else {
            print "error \n";
        }
        print "key ", $char, "\n";
    }
}


my $active_player = 'a';
my $board = `./game_engine.bash -0`;
print $board;

while (true) {
    my $move_col;
    if($active_player eq 'a'){
        $move_col = $player_a->getCol9();
    } else {
        $move_col = $player_b->getCol9();
    }
    my $move = "$active_player:$move_col";
    print $move, "\n";

    print "./game_engine.bash -s -m $move -b $board \n";

    my $step = `./game_engine.bash -s -m $move -b $board`;
    print $step;

    my @step = split(/\n/, $step);
    $board = $step[0];
    my $cp = $step[1];
    my @cp = split(/:/, $cp);
    # print $cp[0], $cp[1], "\n";

    $player_a->inform_board($board);
    $player_b->inform_board($board);

    if ($cp[0] eq "current_player" && $cp[1] ne $active_player) {
        if ($active_player eq 'a'){
            $active_player = 'b';
        } else {
            $active_player = 'a'
        }
    } elsif ($cp[0] eq "won_by"){
        $player_a->inform_win($cp[1]);
        $player_b->inform_win($cp[1]);
    }

}
