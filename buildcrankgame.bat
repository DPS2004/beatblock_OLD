rmdir /s /q release
boon build . --target all
call winhhtpjs.bat "https://github.com/love2d/love/releases/download/11.3/love-11.3-android-embed.apk" -saveTo "release\love-11.3-android-embed.apk" 
cd release
rmdir /s /q love_decoded
call apktool d -s -o love_decoded love-11.3-android-embed.apk
cd love_decoded
del AndroidManifest.xml
del apktool.yml
mkdir assets
cd..

copy Beatblock.love love_decoded\assets\game.love
echo "TODO: set icon to beatblock icon"
cd..

copy AndroidManifest.xml release\love_decoded\AndroidManifest.xml
copy apktool.yml release\love_decoded\apktool.yml
cd release
call apktool b -o beatblock.apk love_decoded
cd..