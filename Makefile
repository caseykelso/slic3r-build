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
CMAKE.VERSION=3.14.4
CMAKE.ARCHIVE=v$(CMAKE.VERSION).tar.gz
CMAKE.URL=https://github.com/Kitware/CMake/archive/$(CMAKE.ARCHIVE)
CMAKE.DIR=$(DOWNLOADS.DIR)/cmake-$(CMAKE.VERSION)
CMAKE.BIN=$(INSTALLED.HOST.DIR)/bin/cmake
BOOST.MAJOR.VERSION=1
BOOST.MINOR.VERSION=69
BOOST.RC.VERSION=0
BOOST.ARCHIVE=boost_$(BOOST.MAJOR.VERSION)_$(BOOST.MINOR.VERSION)_$(BOOST.RC.VERSION).tar.gz
BOOST.URL=https://dl.bintray.com/boostorg/release/$(BOOST.MAJOR.VERSION).$(BOOST.MINOR.VERSION).$(BOOST.RC.VERSION)/source/$(BOOST.ARCHIVE)
BOOST.DIR=$(DOWNLOADS.DIR)/boost_$(BOOST.MAJOR.VERSION)_$(BOOST.MINOR.VERSION)_$(BOOST.RC.VERSION)
WXWIDGETS.VERSION=3.1.2
WXWIDGETS.ARCHIVE=wxWidgets-$(WXWIDGETS.VERSION).tar.bz2
WXWIDGETS.URL=https://github.com/wxWidgets/wxWidgets/releases/download/v$(WXWIDGETS.VERSION)/$(WXWIDGETS.ARCHIVE)
WXWIDGETS.DIR=$(DOWNLOADS.DIR)/wxWidgets-$(WXWIDGETS.VERSION)
SLIC3R.DIR=$(BASE.DIR)/Slic3r
SLIC3R.BUILD=$(BASE.DIR)/build.slic3r

slic3r: slic3r.clean
	mkdir -p $(SLIC3R.BUILD) && cd $(SLIC3R.build) && $(CMAKE.BIN) -DBOOST_LIBRARYDIR=$(INSTALLED.HOST.DIR)/lib -DBOOST_ROOT=$(INSTALLED.HOST.DIR) -DCMAKE_PREFIX_PATH=$(INSTALLED.HOST.DIR) -DCMAKE_INSTALL_PATH=$(INSTALLED.HOST.DIR) $(SLIC3R.DIR)/src && make -j$(J)

slic3r.clean: .FORCE
	rm -rf $(SLIC3R.BUILD)

run: .FORCE
ifeq ($(OS), Darwin)
	export DYLD_LIBRARY_PATH=$(INSTALLED.HOST.DIR)/lib  $(INSTALLED.HOST.DIR)/slic3r.app/Contents/MacOS/slic3r
endif
ifeq ($(OS), Linux)
	export LD_LIBRARY_PATH=$(INSTALLED.HOST.DIR)/lib  $(INSTALLED.HOST.DIR)/bin/slic3r
endif

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

boost.clean: .FORCE
	rm -rf $(BOOST.DIR)
	rm -rf $(DOWNLOADS.DIR)/$(BOOST.ARCHIVE)

boost.fetch: boost.clean
	cd $(DOWNLOADS.DIR) && wget $(BOOST.URL) && tar xf $(BOOST.ARCHIVE)

boost: boost.fetch
	cd $(BOOST.DIR) && ./bootstrap.sh --prefix=$(INSTALLED.HOST.DIR)  && ./b2 cxxstd=17 threading=multi --without-python --without-wave  --without-serialization --without-graph --without-graph_parallel --withoutcontract --without-context --without-container --without-math --without-mpi --without-random --without-regex --without-atomic --without-type_erasure --without-test --without-stacktrace  --without-fiber --build-type=minimal  && ./b2 install threading=multi link=static,shared

cmake.fetch: .FORCE
	mkdir -p $(DOWNLOADS.DIR) && cd $(DOWNLOADS.DIR) && wget -q $(CMAKE.URL) && tar xf $(CMAKE.ARCHIVE)

cmake: cmake.fetch
	cd $(CMAKE.DIR) && ./configure --prefix=$(INSTALLED.HOST.DIR) --no-system-zlib && make -j$(J) && make install

cmake.clean: .FORCE
	rm -rf $(CMAKE.DIR)

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


