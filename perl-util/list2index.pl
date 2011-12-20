#!/opt/local/bin/perl
use JSON;
use File::Spec;
use File::Basename;
use Image::Magick;
use Scalar::Util qw(looks_like_number);
my $dir;
for $dir ( @ARGV){
	die "not directory: $dir" unless -d $dir ;
	$dir = File::Spec->rel2abs( $dir );
	
	my $file = "$dir/index.json";
	
	my $n = basename($dir);
	my $ind = { title => $n  , images => [] };
	$n =~ /^(\d\d\d\d)[-_]\d\d[-_]\d\d/;
	if( $1 ){
	  $ind->{parent}=$1;
	}
	opendir(my $dh, $dir) || die "can't opendir $dir: $!";
	my @jpgs = grep { /\.[jJ][pP][gG]$/ } readdir($dh);
	closedir $dh;
	
	    
	for ( my $i = 0 ; $i < scalar(@jpgs) ; $i++  ) {
	  my $j = $jpgs[$i] ;
	  if( $j =~ /(\.[^\.]+)$/ ){
		    my $name = $` ;
		    my $ext = $1;
		    $image= new Image::Magick;
		    $image->Read("$dir/$name$ext");
		    my($w,$h) = $image->Get("width","height");
		    my @exif = split(/[\r\n]/, $image->Get('format', '%[EXIF:*]'));
		    my $exifMap = {};
		    if( scalar(@exif) > 0 ){
			  for(@exif){
			  	my(@kv) = split( /[:=]/,$_); 
			    $exifMap->{$kv[1]} = $kv[2];
			  }
			}
			my $o = $exifMap->{Orientation};
			print "$j $name $ext $w $h %$exifMap $i $o\n";	
			$ind->{images}[$i] = { 
		  		type => "image", 
		  		name => $name, 
		  		ext => $ext,
		  		width => $w,  
		  		height => $h, 
		  		exif => $exifMap,
		  		applyRotation => 1,
		  		highlight => 0, 
		  	};
	  }
	}
	print "$file\n";
	
	open my $f1, ">", $file or die "could not open $file: $!";
	print $f1 to_json( $ind , { utf8 => 1, pretty => 1 } );
	close $f1;
	my $parentFile=dirname($dir)."/".$ind->{parent}."/index.json" ;
	my $document = from_json( do {
      local $/ = undef;
      open my $fh, "<", $parentFile or die "could not open $parentFile: $!";
      <$fh>;
    });
    
    splice @{$document->{images}} , 0, 0, {
         name => $n,
         type => album,
         highlight => 0,
    };
    
	open my $f1, ">", $parentFile or die "could not open $parentFile: $!";
	print $f1 to_json( $document , { utf8 => 1, pretty => 1 } );
	close $f1;
}



