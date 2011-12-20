package resize;
use nginx;
use File::Path qw(mkpath);
use File::Basename;
use Image::Magick;

our $base_dir="/var/pictures/";
our $cache_dir="/var/pictures_resized/";
our $image;

sub handler {
 my $r = shift;
 
 my $uri=$r->uri;
 $uri=~ s!^/resize!!;
 
 return DECLINED unless $uri =~ m/\.resize_to\.(\d{1,}?)x(\d{1,}?)(r\d|)\./;
 my($base,$ext,$width,$height,$rotate) = ($`,$',$1,$2,$3);
 my $dest_file="$cache_dir/$uri";
 
 unless( -f $dest_file ){
     mkpath(dirname($dest_file));
     my $real_file_path="$base_dir/$base.$ext";

     return DECLINED unless -f $real_file_path;

     $image= new Image::Magick;
     $image->Read($real_file_path);
     $image->Strip();
     if( $rotate eq "r6" ){
     	$image->Scale($height);
     	$image->Flip; 
     	$image->Transpose; 
     }elsif( $rotate eq "r3" ) { 
     	$image->Scale($width);
     	$image->Flip; 
     	$image->Flop; 
     }elsif( $rotate eq "r8" ) { 
     	$image->Scale($height);
     	$image->Flip; $image->Transverse; 
     }else{
     	$image->Scale($width);
     }
     $image->Write($dest_file);
 }
 $r->sendfile($dest_file);
 return OK;

}

1;
__END__
