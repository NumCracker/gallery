#!/opt/local/bin/perl
use JSON;
use Image::Magick;
use Scalar::Util qw(looks_like_number);

my $file = shift @ARGV;
die "not album.json: $file" unless $file =~ /album.json$/ ;

sub read_json {
    my($file)=@_;
    return from_json( do {
	local $/ = undef;
	open my $fh, "<", $file or die "could not open $file: $!";
	<$fh>;
    }, { utf8 => 1 } );
}

my $album = read_json( $file );
my $dir = $file; 
$dir =~ s/album.json$//;
$file =~ s/album.json$/photos.json/;
my $photos = read_json( $file );
$file =~ s/photos.json$/index.json/;



my $h = { title => $album->{fields}{title}  ,
images => [] };

my $parent = $album->{fields}{parentAlbumName};
if( $parent ){
  $h->{parent}=$parent;
}
for ( my $i = 0 ; $i < scalar(@$photos) ; $i++  ) {
  my $img = $$photos[$i] ;
  my $highlight = $img->{highlight} ? 1 : 0 ;
  my $x;
  if( $img->{isAlbumName} ){
  	$x = { 
  		type => "album", 
  		name => $img->{isAlbumName} 
  	};
  }else{
    my $name = $img->{image}{name} ;
    my $ext = ".".$img->{image}{type};
    my $exifMap = {};
    $image= new Image::Magick;
    $image->Read("$dir$name$ext");
    my($w,$h) = $image->Get("width","height");
    my @exif = split(/[\r\n]/, $image->Get('format', '%[EXIF:*]'));
    if( scalar(@exif) > 0 ){
	  for(@exif){
	  	my(@kv) = split( /[:=]/,$_); 
	    $exifMap->{$kv[1]} = $kv[2];
	  }
	}
  	$x = { 
  		type => "image", 
  		name => $name, 
  		ext => $ext,
  		width => $img->{image}{raw_width},  
  		height => $img->{image}{raw_height}, 
  		exif => $exifMap, 
  	};
  }
  $h->{images}[$i] = $x;
  $h->{highlight} = $x if $highlight ;
  $h->{images}[$i]{highlight} = $highlight;
}
open my $f1, ">", $file or die "could not open $file: $!";
print $f1 to_json( $h , { utf8 => 1, pretty => 1 } );
close $f1;




