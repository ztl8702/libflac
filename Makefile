EMCC:=emcc
EMCC_DEF_OPT_LEVEL:=-O1
EMCC_MAX_OPT_LEVEL:=-O0 -g4
EMCC_MIN_OPT_LEVEL:=-O3
EMCC_OPTS:=-s NO_EXIT_RUNTIME=1 -s LINKABLE=1 -s RESERVED_FUNCTION_POINTERS=5 -s ALLOW_MEMORY_GROWTH=1 -s EXPORTED_FUNCTIONS='["_FLAC__stream_encoder_set_verify","_FLAC__stream_encoder_set_compression_level","_FLAC__stream_encoder_set_blocksize","_FLAC__stream_encoder_new","_FLAC__stream_encoder_set_channels","_FLAC__stream_encoder_set_bits_per_sample","_FLAC__stream_encoder_set_sample_rate","_FLAC__stream_encoder_set_total_samples_estimate","_FLAC__stream_decoder_new","_FLAC__stream_decoder_set_md5_checking","_FLAC__stream_encoder_init_stream","_FLAC__stream_decoder_init_stream","_FLAC__stream_encoder_process_interleaved","_FLAC__stream_decoder_process_single","_FLAC__stream_decoder_process_until_end_of_stream","_FLAC__stream_decoder_process_until_end_of_metadata","_FLAC__stream_decoder_get_state","_FLAC__stream_encoder_get_state","_FLAC__stream_decoder_get_md5_checking","_FLAC__stream_encoder_finish","_FLAC__stream_decoder_finish","_FLAC__stream_decoder_reset","_FLAC__stream_encoder_delete","_FLAC__stream_decoder_delete"]'
EMCONFIGURE:=emconfigure
EMMAKE:=emmake
TAR:=tar
XZ:=xz

PREFILE=libflac_pre.js
POSTFILE=libflac_post.js

FLAC_VERSION:=1.3.2
FLAC:=flac-$(FLAC_VERSION)
FLAC_URL:="http://downloads.xiph.org/releases/flac/$(FLAC).tar.xz"

all: dist/libflac-$(FLAC_VERSION).js dist/libflac-$(FLAC_VERSION).min.js dist/libflac-$(FLAC_VERSION).max.js

dist/libflac-$(FLAC_VERSION).js: $(FLAC) $(PREFILE) $(POSTFILE)
	$(EMCC) $(EMCC_DEF_OPT_LEVEL) $(EMCC_OPTS) --pre-js $(PREFILE) --post-js $(POSTFILE) $(wildcard $(FLAC)/src/libFLAC/.libs/*.o) -o $@

dist/libflac-$(FLAC_VERSION).min.js: $(FLAC) $(PREFILE) $(POSTFILE)
	$(EMCC) $(EMCC_MIN_OPT_LEVEL) $(EMCC_OPTS) --pre-js $(PREFILE) --post-js $(POSTFILE) $(wildcard $(FLAC)/src/libFLAC/.libs/*.o) -o $@

dist/libflac-$(FLAC_VERSION).dev.js: $(FLAC) $(PREFILE) $(POSTFILE)
	$(EMCC) $(EMCC_MAX_OPT_LEVEL) $(EMCC_OPTS) --pre-js $(PREFILE) --post-js $(POSTFILE) $(wildcard $(FLAC)/src/libFLAC/.libs/*.o) -o $@

dist/libflac-vs-$(FLAC_VERSION).js: $(FLAC) $(PREFILE) $(POSTFILE)
	$(EMCC) $(EMCC_DEF_OPT_LEVEL) $(EMCC_OPTS) -s USE_OGG=1 --pre-js $(PREFILE) --post-js $(POSTFILE) $(wildcard $(FLAC)/src/libFLAC/Emscripten/Release/*.o) -o $@

dist/libflac-vs-$(FLAC_VERSION).min.js: $(FLAC) $(PREFILE) $(POSTFILE)
	$(EMCC) $(EMCC_MIN_OPT_LEVEL) $(EMCC_OPTS) -s USE_OGG=1 --pre-js $(PREFILE) --post-js $(POSTFILE) $(wildcard $(FLAC)/src/libFLAC/Emscripten/Release/*.o) -o $@

emccvs: dist/libflac-vs.js dist/libflac-vs.min.js

emmake: $(FLAC)
	cd $(FLAC) && \
	$(EMMAKE) make

$(FLAC): $(FLAC).tar.xz
	$(XZ) -dc $@.tar.xz | $(TAR) -xv && \
	cd $@ && \
	$(EMCONFIGURE) ./configure --disable-asm-optimizations --disable-3dnow --disable-altivec --disable-thorough-tests --disable-doxygen-docs --disable-xmms-plugin --disable-cpplibs --disable-ogg --disable-oggtest && \
	$(EMMAKE) make

$(FLAC).tar.xz:
	test -e "$@" || wget $(FLAC_URL)

clean:
	$(RM) -rf $(FLAC)

distclean: clean
	$(RM) $(FLAC).tar.xz

compclean:
	cd $(FLAC) && \
	make clean

.PHONY: clean distclean
