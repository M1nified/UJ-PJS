package Player;

use IO::Handle;
use IO::Pipe;
use IO::Select;
use Digest::MD5;

my $web_server = 0;
my $ws_pipe = 0;

sub new {
    my $class = shift;
    my $key = Digest::MD5::md5_hex(map { sprintf q|%X|, rand(16) } 1 .. 10);
    my $self = {
    _player => shift,
    _type => shift,
    _key => $key,
    _board => ""
    };
    print "Player ", $self->{_player} ," type is ", $self->{_type}, "\n";
    if ($self->{_type} eq 'browser') {
        if ($web_server eq 0){
            #    $web_server = new WebServer();
        }
        if ($ws_pipe == 0){
            print "make pipe";
            $ws_pipe = IO::Pipe->new();
            $io = IO::Handle->new();
            open(my $fh, "|tr '[a-z]' '[A-Z]'");
            # $io->fdopen();
            $ws_pipe->writer();
            open(WS_FIFO, "> webserver.pipe");
        }
    }
    bless $self, $class;
    return $self;
}

sub cout {
    my( $self, $msg ) = @_;
    if ($self->{_type} eq 'human') {
        print $msg;
    }
}

sub inform_active_player {
    my ($self, $active_player) = @_;
    if ($self->{_type} eq 'human') {
        print "This is turn of player: $active_player\n";
    } elsif ($self->{_type} eq 'browser') {
        print WS_FIFO "current_player:$active_player\n";
    }
}

sub inform_key {
    my ($self, $board) = @_;
    if ($self->{_type} eq 'human') {
        
    } elsif ($self->{_type} eq 'browser') {
        my $key = $self->{_key};
        my $player = $self->{_player};
        print WS_FIFO "player_key:$player:$key\n";
    }
}

sub inform_board {
    my ($self, $board) = @_;
    $self->{_board} = $board;
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
        for my $i (1..$bx*2+1) {
            print "-";
        }
        print "\n|";
        for my $i (1..$bx) {
            print "$i|";
        }
        # print "\n|";
        for my $i (0..$blen) {
            if ( $i % $bx == 0 && $i < $blen ) {
                print "\n|";
            }
            print $bdisp[$i];
            if ( $i < $blen) {
                print "|";
            }
        }
        print "\n";
        for my $i (1..$bx*2+1) {
            print "-";
        }
        print "\n";
    } elsif ($self->{_type} eq 'browser') {
        print WS_FIFO "$board\n";
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
        print "Please, type column number: ";
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
    } elsif ($self->{_type} eq 'computer') {
        my $board = $self->{_board};
        my $player = $self->{_player};
        # print "./virtual_player.py -b $board -p $player\n";
        my $move = `./virtual_player.py -b $board -p $player`;
        # print "pc moved $move\n";
        return $move;
    } elsif ($self->{_type} eq 'browser') {
        return 1;
    }
}

1
