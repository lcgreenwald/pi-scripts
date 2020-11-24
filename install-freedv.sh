cd
sudo apt install -y cmake subversion libwxgtk3.0-dev portaudio19-dev libusb-1.0-0-dev libsamplerate0-dev libasound2-dev libao-dev libgsm1-dev libsndfile1-dev libjpeg9-dev libxft-dev libxinerama-dev libxcursor-dev libspeex-dev libspeexdsp-dev
git clone https://github.com/drowe67/freedv-gui.git
cd freedv-gui
./build_linux.sh
cd build_linux
sudo make install
cd
