FROM ubuntu:trusty

RUN apt-get update && apt-get install -y git curl make libtool automake pkg-config python-pip

# test requirements
RUN pip install tox

## python interpreters
RUN apt-get install -y software-properties-common python-software-properties && \
    add-apt-repository -y ppa:fkrull/deadsnakes && \
    apt-get update && \
    apt-get install -y python3.5 python3.4 python3.3 python3.2 python2.7 python2.6

# installing libsodium, needed for toxcore
RUN git clone https://github.com/jedisct1/libsodium.git && \
cd libsodium && git checkout tags/1.0.3 && ./autogen.sh && ./configure --prefix=/usr && make && make install

# installing libopus, needed for audio encoding/decoding
RUN curl -fsSL http://downloads.xiph.org/releases/opus/opus-1.1.2.tar.gz | \
    tar xz && \
    cd opus-1.1.2 && ./configure && make && make install

# installing vpx
RUN apt-get install -y yasm && \
    git clone https://chromium.googlesource.com/webm/libvpx && \
    cd libvpx && ./configure --enable-shared && make && make install

# creating librarys' links and updating cache
RUN ldconfig && \
    git clone https://github.com/irungentoo/toxcore.git && \
    cd toxcore && autoreconf -i && ./configure --prefix=/usr --disable-tests --disable-ntox && \
    make && make install

# PyTox
RUN sudo apt-get install -y python-dev
ADD pytox PyTox/pytox
ADD setup.py PyTox/setup.py
ADD examples PyTox/examples
ADD tests PyTox/tests
ADD MANIFEST.in PyTox/MANIFEST.in
ADD tox.ini PyTox/tox.ini
RUN cd PyTox && python setup.py install
