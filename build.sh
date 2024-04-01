cd /Users/tristan/Desktop/video_tester
flutter build ipa --release

if [[ $? -ne 0 ]] 
then exit
fi

sleep 2
cd build/ios/archive/Runner.xcarchive/Products/Applications
mkdir ~/Desktop/Payload
cp -r Runner.app ~/Desktop/Payload
cd ~/Desktop
zip -r ~/Desktop/VideoTester.ipa Payload
rm -r Payload
