HASH := $(shell git rev-parse --short=10 HEAD)
OS := $(shell uname)
ARCH := $(shell uname -m)
ifeq ($(OS), Linux)
J := $(shell nproc --all)
endif

ifeq ($(OS), Darwin)
#J := $(shell system_profiler | awk '/Number of CPUs/ {print $$4}{next;}')
J := 12
endif

BASE.DIR=$(PWD)
BUILD.PREFIX=build
DOWNLOADS.DIR=$(BASE.DIR)/downloads
INSTALLED.HOST.DIR=$(BASE.DIR)/installed.host
INSTALLED.TARGET.DIR=$(BASE.DIR)/installed.target
DEPLOYED.HOST.DIR=$(BASE.DIR)/deployed.host
DISTRIBUTION.HOST.DIR=$(BASE.DIR)/distribution.host
CMAKE.PREBUILT.VERSION.MAJOR=3
CMAKE.PREBUILT.VERSION.MINOR=10
CMAKE.PREBUILT.VERSION.RC=2
CMAKE.PREBUILT.OSX.HASH=85c245a8fa
CMAKE.PREBUILT.OSX.ARCHIVE=cmake-$(CMAKE.PREBUILT.VERSION.MAJOR)-$(CMAKE.PREBUILT.VERSION.MINOR)-$(CMAKE.PREBUILT.VERSION.RC)-osx-$(ARCH)-$(CMAKE.PREBUILT.OSX.HASH).tar.gz
CMAKE.PREBUILT.OSX.URL=https://s3.amazonaws.com/mutex-io-artifacts-public/cmake/$(CMAKE.PREBUILT.OSX.ARCHIVE)
CMAKE.PREBUILT.LINUX.HASH=0c37b4d663
CMAKE.PREBUILT.LINUX.ARCHIVE=cmake-$(CMAKE.PREBUILT.VERSION.MAJOR)-$(CMAKE.PREBUILT.VERSION.MINOR)-$(CMAKE.PREBUILT.VERSION.RC)-linux-$(ARCH)-$(CMAKE.PREBUILT.LINUX.HASH).tar.gz
CMAKE.PREBUILT.LINUX.URL=https://s3.amazonaws.com/mutex-io-artifacts-public/cmake/$(CMAKE.PREBUILT.LINUX.ARCHIVE)
CMAKE.URL=https://s3.amazonaws.com/buildroot-sources/cmake-3.10.2.tar.gz
CMAKE.DIR=$(DOWNLOADS.DIR)/cmake-3.10.2
CMAKE.ARCHIVE=$(DOWNLOADS.DIR)/cmake-3.10.2.tar.gz
CMAKE.BIN=$(INSTALLED.HOST.DIR)/bin/cmake
GLM.ARCHIVE=glm-0.9.9.5.zip
GLM.URL=https://github.com/g-truc/glm/releases/download/0.9.9.5/$(GLM.ARCHIVE)
GLM.DIR=$(DOWNLOADS.DIR)/glm
GLM.BUILD.DIR=$(DOWNLOADS.DIR)/build.glm
BOOST.MAJOR.VERSION=1
BOOST.MINOR.VERSION=68
BOOST.RC.VERSION=0
BOOST.ARCHIVE=boost_$(BOOST.MAJOR.VERSION)_$(BOOST.MINOR.VERSION)_$(BOOST.RC.VERSION).tar.gz
BOOST.URL=https://dl.bintray.com/boostorg/release/$(BOOST.MAJOR.VERSION).$(BOOST.MINOR.VERSION).$(BOOST.RC.VERSION)/source/$(BOOST.ARCHIVE)
BOOST.DIR=$(DOWNLOADS.DIR)/boost_$(BOOST.MAJOR.VERSION)_$(BOOST.MINOR.VERSION)_$(BOOST.RC.VERSION)
FFI.ARCHIVE=v3.2.1.tar.gz
FFI.URL=https://github.com/libffi/libffi/archive/$(FFI.ARCHIVE)
FFI.DIR=$(DOWNLOADS.DIR)/libffi-3.2.1
WXWIDGETS.VERSION=3.1.2
WXWIDGETS.ARCHIVE=wxWidgets-$(WXWIDGETS.VERSION).tar.bz2
WXWIDGETS.URL=https://github.com/wxWidgets/wxWidgets/releases/download/v$(WXWIDGETS.VERSION)/$(WXWIDGETS.ARCHIVE)
WXWIDGETS.DIR=$(DOWNLOADS.DIR)/wxWidgets-$(WXWIDGETS.VERSION)
XZ.VERSION=5.2.4
XZ.ARCHIVE=xz-$(XZ.VERSION).tar.gz
XZ.URL=https://tukaani.org/xz/$(XZ.ARCHIVE)
XZ.DIR=$(DOWNLOADS.DIR)/xz-$(XZ.VERSION)
BISON.VERSION=3.1
BISON.ARCHIVE=bison-$(BISON.VERSION).tar.gz
BISON.URL=http://gnu.mirrors.hoobly.com/bison/$(BISON.ARCHIVE)
BISON.DIR=$(DOWNLOADS.DIR)/bison-$(BISON.VERSION)
SLIC3R.DIR=$(BASE.DIR)/Slic3r
SLIC3R.BUILD=$(BASE.DIR)/build.slic3r

slic3r: slic3r.clean
	mkdir -p $(SLIC3R.BUILD) && cd $(SLIC3R.build) && $(CMAKE.BIN) -DCMAKE_PREFIX_PATH=$(INSTALLED.HOST.DIR) -DCMAKE_INSTALL_PATH=$(INSTALLED.HOST.DIR) $(SLIC3R.DIR)/src && make -j$(J) install

slic3r.clean: .FORCE
	rm -rf $(SLIC3R.BUILD)

run: .FORCE
ifeq ($(OS), Darwin)
	export DYLD_LIBRARY_PATH=$(INSTALLED.HOST.DIR)/lib  $(INSTALLED.HOST.DIR)/slic3r.app/Contents/MacOS/slic3r
endif
ifeq ($(OS), Linux)
	export LD_LIBRARY_PATH=$(INSTALLED.HOST.DIR)/lib  $(INSTALLED.HOST.DIR)/bin/slic3r
endif

bison: .FORCE
	rm -rf $(DOWNLOADS.DIR)/$(BISON.ARCHIVE)
	rm -rf $(BISON.DIR)
	mkdir -p $(DOWNLOADS.DIR) && cd $(DOWNLOADS.DIR) && wget -q $(BISON.URL) && tar xf $(DOWNLOADS.DIR)/$(BISON.ARCHIVE)
	cd $(BISON.DIR) && ./configure --prefix=$(INSTALLED.HOST.DIR) && make -j$(J) && make install

wxwidgets: wxwidgets.clean
ifeq ($(OS), Darwin)
	mkdir -p $(DOWNLOADS.DIR) && cd $(DOWNLOADS.DIR) && wget $(WXWIDGETS.URL) && tar xf $(WXWIDGETS.ARCHIVE)
	cd $(WXWIDGETS.DIR) && ./configure --prefix=$(INSTALLED.HOST.DIR) CPPFLAGS=-D__ASSERT_MACROS_DEFINE_VERSIONS_WITHOUT_UNDERSCORES=1 --with-opengl --enable-aui --enable-html --enable-stl --with-libjpeg=builtin --with-libpng=builtin --with-regex=builtin --with-libtiff=builtin --with-zlib=builtin --with-expat=builtin --without-liblzma --with-osx_cocoa --disable-mediactrl --disable-utf8 --disable-utf8only  --with-macosx-version-min=10.14 --with-macosx-sdk=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.14.sdk && make -j$(J) install
endif

ifeq ($(OS), Linux)
	mkdir -p $(DOWNLOADS.DIR) && cd $(DOWNLOADS.DIR) && wget $(WXWIDGETS.URL) && tar xf $(WXWIDGETS.ARCHIVE)
	cd $(WXWIDGETS.DIR) && ./configure --prefix=$(INSTALLED.HOST.DIR) CPPFLAGS=-D__ASSERT_MACROS_DEFINE_VERSIONS_WITHOUT_UNDERSCORES=1 --with-opengl-builtin --enable-aui --enable-html --enable-stl --with-libjpeg=builtin --with-libpng=builtin --with-regex=builtin --with-libtiff=builtin --with-zlib=builtin --with-expat=builtin --without-liblzma --disable-mediactrl --disable-utf8 --disable-utf8only && make -j$(J) install
endif


wxwidgets.clean: .FORCE
	rm -rf $(WXWIDGETS.DIR)
	rm -f $(DOWNLOADS.DIR)/$(WXWIDGETS.ARCHIVE)

xz: xz.clean
	mkdir -p $(DOWNLOADS.DIR) && cd $(DOWNLOADS.DIR) && wget $(XZ.URL) && tar xf $(XZ.ARCHIVE)
	cd $(XZ.DIR) && ./configure --prefix=$(INSTALLED.HOST.DIR) && make -j$(J) install

xz.clean: .FORCE
	rm -rf $(XZ.DIR)
	rm -f $(DOWNLOADS.DIR)/$(XZ.ARCHIVE)

ffi: ffi.clean
	mkdir -p $(DOWNLOADS.DIR) && cd $(DOWNLOADS.DIR) && wget $(FFI.URL) && tar xf $(FFI.ARCHIVE)
	cd $(FFI.DIR) && ./autogen.sh && ./configure --prefix=$(INSTALLED.HOST.DIR) && make -j$(J) install

ffi.clean: .FORCE
	rm -rf $(FFI.DIR)
	rm -f $(DOWNLOADS.DIR)/$(FFI.ARCHIVE)

glm: glm.clean
	mkdir -p $(DOWNLOADS.DIR)
	cd $(DOWNLOADS.DIR) && wget $(GLM.URL) && unzip $(GLM.ARCHIVE)
	mkdir -p $(GLM.BUILD.DIR) && cd $(GLM.BUILD.DIR) && $(CMAKE.BIN) -DCMAKE_INSTALL_PREFIX=$(INSTALLED.HOST.DIR) -DCMAKE_PREFIX_PATH=$(INSTALLED.HOST.DIR) $(GLM.DIR) && make -j1  install

glm.clean: .FORCE
	rm -f $(DOWNLOADS.DIR)/$(GLM.ARCHIVE)
	rm -rf $(GLM.DIR)
	rm -rf $(GLM.BUILD.DIR)

boost.clean: .FORCE
	rm -rf $(BOOST.DIR)
	rm -rf $(DOWNLOADS.DIR)/$(BOOST.ARCHIVE)

boost.fetch: boost.clean
	cd $(DOWNLOADS.DIR) && wget $(BOOST.URL) && tar xf $(BOOST.ARCHIVE)

boost: boost.fetch
	cd $(BOOST.DIR) && ./bootstrap.sh --prefix=$(INSTALLED.HOST.DIR)  && ./b2 threading=multi link=shared --without-python --without-wave --without-type_erasure --without-test --without-stacktrace  --without-fiber --build-type=minimal  && ./b2 install threading=multi link=shared 

cmake.fetch: .FORCE
	mkdir -p $(DOWNLOADS.DIR) && cd $(DOWNLOADS.DIR) && wget -q $(CMAKE.URL) && tar xf $(CMAKE.ARCHIVE)

cmake: cmake.fetch
	cd $(CMAKE.DIR) && ./configure --prefix=$(INSTALLED.HOST.DIR) --no-system-zlib && make -j$(J) && make install

cmake.clean: .FORCE
	rm -rf $(CMAKE.DIR)

swig: swig.build #swig.clean swig.fetch swig.unpack swig.build

swig.clean: .FORCE
	rm -rf $(DOWNLOADS.DIR)/$(SWIG.ARCHIVE)
	rm -rf $(DOWNLOADS.DIR)/$(SWIG.DIR)
	
swig.fetch: .FORCE
	mkdir -p $(DOWNLOADS.DIR)
	cd $(DOWNLOADS.DIR) && wget $(SWIG.URL)

swig.unpack: .FORCE
	cd $(DOWNLOADS.DIR) && tar xf $(SWIG.ARCHIVE)

swig.build: .FORCE
	export PATH=$(PATH):$(INSTALLED.HOST.DIR)/bin && cd $(SWIG.DIR) && ./autogen.sh && ./configure --prefix=$(INSTALLED.HOST.DIR) && PATH=$(PATH):$(INSTALLED.HOST.DIR)/bin make -j8 && make install

submodule: .FORCE
	git submodule init
	git submodule update

clean: .FORCE
	rm -rf $(INSTALLED.HOST.DIR)
	rm -rf $(DOWNLOADS.DIR)


ctags: .FORCE
	cd $(BASE.DIR) Slic3r && ctags -R --exclude=.git .

ci: cmake submodule boost wxwidgets slic3r
	
.FORCE:


