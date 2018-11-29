#!/usr/bin/perl

use Player;

my($p1, $p2);

sub print_help(){
    my $help = "usage: $0 [-h] PLAYER_1_TYPE PLAYER_2_TYPE\
\
Starts game between two players.\
\
PLAYER_TYPE can be one of following strings:\
    human\
    computer\
\
optional arguments:\
    -h, --help          show this help message and exit\
";
    print $help, "\n";
}

while(scalar @ARGV gt 0){
    my $arg = shift;
    if($arg eq "-h" || $arg eq "--help"){
        print_help();
        exit(0);
    }elsif($arg =~ m/(human|computer)/){
        if($p1 eq ""){
            $p1 = $arg;
        }elsif($p2 eq ""){
            $p2 = $arg;
        }
    }else{
        print "Error: Unknown argument '", $arg, "'.\n\n";
        print_help();
        exit(1);
    }
}


if($p1 eq ""){
    print "Error: First player type is required.\n\n";
    print_help();
    exit(1);
}
if($p2 eq ""){
    print "Error: Second player type is required.\n\n";
    print_help();
    exit(1);
}

# print $p1, "\n", $p2, "\n";

sub parse_player {
    my ($string) = @_;
    my @cp = split(/:/, $string);
    return $cp[1];
}

# my $player_a = new Player('a', 'browser');
my $player_a = new Player('a', $p1);
my $player_b = new Player('b', $p2);

$player_a->inform_key();
$player_b->inform_key();

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
my $board = `./game_engine.sh -0`;
print $board;

while (true) {
    my $move_col;
    $player_a->inform_active_player($active_player);
    $player_b->inform_active_player($active_player);
    if($active_player eq 'a'){
        $move_col = $player_a->getCol9();
    } else {
        $move_col = $player_b->getCol9();
    }
    my $move = "$active_player:$move_col";
    print $move, "\n";

    print "./game_engine.sh -s -m $move -b $board \n";

    my $step = `./game_engine.sh -s -m $move -b $board`;
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
