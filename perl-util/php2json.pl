#!/opt/local/bin/perl
use PHP::Serialization qw(serialize unserialize);
use JSON ;
use Scalar::Util qw(looks_like_number);

my $file = shift @ARGV;
my $document = do {
    local $/ = undef;
    open my $fh, "<", $file or die "could not open $file: $!";
    <$fh>;
};

$file =~ s/dat$/json/;
print "$file\n";

my $h = unserialize($document);
my $raw = &recur($h);
#print $raw;
open my $f1, ">", $file or die "could not open $file: $!";
print $f1 to_json( from_json( $raw, { utf8  => 1 } ) , { utf8 => 1, pretty => 1 } );
close $f1;

sub recur{
    my ($r,$nn)=@_; 
    my ($j)="";
    if( ref($r) eq 'ARRAY' ){
	for(@$r){
	    if( length($j) > 0 ){
		$j .= ", ";
	    }
	    $j .= &recur( $_ );
	    $j .= "\n";
	}
	"[ $j ]";
    }elsif( ref($r)  ){
	for(keys %$r){
            if( length($j) > 0 ){
		$j .= ", ";
            }
	    $j .= &recur( $_ , 1);
	    $j .= " : ";
	    $j .= &recur( $r->{$_} );
	}
	"{ $j }\n";
    }elsif( !$nn && looks_like_number($r)  ){
	$r+0;
    }else{
	"\"$r\"";
    }
}



