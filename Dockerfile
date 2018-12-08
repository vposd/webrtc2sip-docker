FROM ubuntu:xenial
MAINTAINER Valerii Pozdniakov <bigtuness@gmail.com>

WORKDIR /src

ADD config.xml /etc/webrtc2sip/config.xml
RUN apt-get update
RUN apt-get install --no-install-recommends -y git libssl-dev build-essential libtool autoconf automake \
    libogg-dev pkg-config libspeex-dev libspeexdsp-dev wget libsrtp-dev libxml2-dev && rm -rf /var/lib/apt/lists/*

RUN cd /usr/share/dict
RUN wget --no-check-certificate https://sourceforge.net/projects/souptonuts/files/souptonuts/dictionary/linuxwords.1.tar.gz
RUN tar zxvf linuxwords.1.tar.gz && rm linuxwords.1.tar.gz
RUN mv linuxwords.1/linux.words ./words && rm -rf linuxwords.1

RUN wget --no-check-certificate http://downloads.xiph.org/releases/opus/opus-1.0.2.tar.gz \
RUN tar -xvzf opus-1.0.2.tar.gz && cd opus-1.0.2 && ./configure --with-pic --enable-float-approx && make && make install \
RUN apt-get -y remove wget && rm ../opus-1.0.2.tar.gz && rm -rf ../opus-1.0.2

RUN git config --global http.sslVerify false
RUN git clone https://github.com/DoubangoTelecom/doubango.git
RUN cd doubango && ./autogen.sh
RUN ./configure --with-ssl --with-srtp --with-speexdsp --prefix=/usr/local \
RUN make
RUN make install
RUN cd ../ && rm -rf ../doubango

RUN git config --global http.sslVerify false
RUN git clone https://github.com/DoubangoTelecom/webrtc2sip.git
RUN cd webrtc2sip && ./autogen.sh
RUN ./configure CFLAGS='-lpthread' LDFLAGS='-ldl' LIBS='-ldl' \
RUN make
RUN make install
RUN cd ../
RUN rm -rf ../webrtc2sip

RUN
CMD webrtc2sip --config=/etc/webrtc2sip/config.xml