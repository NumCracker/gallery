package json;
use nginx;
use File::Path qw(mkpath);
use Image::Magick;

our $base_dir="/var/pictures/";
our $cache_dir="/var/pictures_resized/";

sub handler{
my $r = shift;
return DECLINED unless $r->uri =~ m/\.json$/;
my $uri=$r->uri;
$uri=~ s!^/json!!;
my $dest_file="$cache_dir/$uri";
unless( -f $dest_file ){
    my @path_tokens=split("/", $uri);
    pop @path_tokens;
    mkpath(join("/", $cache_dir, @path_tokens));
    my $real_path=join("/",   $base_dir, @path_tokens);
    opendir(DIR, $real_path) or return DECLINED;
    my $json = "[";
    while( my $file = readdir(DIR) ){
	if( $file =~ /(.jpg|.JPG|.gif|.GIF|.png|.PNG)$/ ){
	    $json .= "," if length($json) > 1 ;
	    $image= new Image::Magick;
	    $image->Read("$real_path/$file");
	    my($w,$h) = $image->Get("width","height");
	    $file =~ /(.*)(\.[^\.]+)$/;
	    my($n,$e) =  ($1,$2);
	    my @exif = split(/[\r\n]/, $image->Get('format', '%[EXIF:*]'));
	    $json .= " { \"name\" : \"$n\", \"ext\" : \"$e\", \"width\" : $w, \"height\" : $h " ;
	    if( scalar(@exif) > 0 ){
		my $exifJson = "" ;
		for(@exif){
		    if(length($exifJson) > 0 ){
			$exifJson .= ", "
		    }
		    my(@kv) = split( /[:=]/,$_); 
		    $exifJson .= "\"$kv[1]\" : \"$kv[2]\"" ;
		}
		$json .= ", \"exif\" : { $exifJson}" ;
	    }
	    $json .= "}\n" ;
            
	}
    }
    $json .= "]\n";
    closedir(DIR);
    open ( OUT, ">$dest_file");
    print OUT $json;
    close(OUT);
}
$r->send_http_header("application/json");
$r->sendfile($dest_file);
return OK;

}

1;
__END__
