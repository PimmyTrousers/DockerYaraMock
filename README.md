# Yara Mock 

Quick test to show a potential bug within Go Yara, or at least how it interacts with docker. 

UPDATE: As of now the issue is fixed with the commit that Hillu made to the dockerfile. 

# Steps To Recreate
1. `docker build -t dockeryara:latest . && docker run -p 8000:8000 dockeryara:latest `
2. unzip the wannacry_test.zip with password `infected123`
3. execute the following curl command with the proper IP `curl -F "file=@<FULLPATH>/wannacry.bin_" http://<IP>:8000/scanfile -v`
4. If done properly you should see something like the following in stderr of the docker container.
```
fatal error: unexpected signal during runtime execution
[signal SIGSEGV: segmentation violation code=0x1 addr=0x2f pc=0x6aba97]

runtime stack:
runtime.throw(0x76c444, 0x2a)
	/usr/local/go/src/runtime/panic.go:774 +0x72
runtime.sigpanic()
	/usr/local/go/src/runtime/signal_unix.go:378 +0x47c

goroutine 42 [syscall, locked to thread]:
runtime.cgocall(0x6aba60, 0xc0048752a0, 0x1)
	/usr/local/go/src/runtime/cgocall.go:128 +0x5b fp=0xc004875270 sp=0xc004875238 pc=0x40651b
github.com/hillu/go-yara._Cfunc_string_matches(0x7f9f9b65824a, 0x0, 0xc0004dc23c)
	_cgo_gotypes.go:1121 +0x45 fp=0xc0048752a0 sp=0xc004875270 pc=0x6a3d85
github.com/hillu/go-yara.(*String).Matches(0xc0048753c8, 0x0, 0x0, 0x0)
	/go/src/github.com/hillu/go-yara/rule.go:225 +0x6b fp=0xc004875338 sp=0xc0048752a0 pc=0x6a665b
github.com/hillu/go-yara.(*Rule).getMatchStrings(0xc0048c0678, 0x0, 0x0, 0x0)
	/go/src/github.com/hillu/go-yara/rule.go:244 +0x2c2 fp=0xc004875440 sp=0xc004875338 pc=0x6a6ab2
github.com/hillu/go-yara.(*MatchRules).RuleMatching(0xc000086080, 0xc0048c0678, 0xc000086080, 0x7f9fb10b6a08, 0xc000086080)
	/go/src/github.com/hillu/go-yara/rules_callback.go:151 +0x224 fp=0xc0048755a0 sp=0xc004875440 pc=0x6a76f4
github.com/hillu/go-yara.scanCallbackFunc(0x1, 0x7f9f97f2d472, 0x1d1f7e0, 0x7780b0)
	/go/src/github.com/hillu/go-yara/rules_callback.go:90 +0x220 fp=0xc004875680 sp=0xc0048755a0 pc=0x6a7100
github.com/hillu/go-yara._cgoexpwrap_08a63f7e5a95_scanCallbackFunc(0x7f9f00000001, 0x7f9f97f2d472, 0x1d1f7e0, 0x0)
	_cgo_gotypes.go:1621 +0x3d fp=0xc0048756b0 sp=0xc004875680 pc=0x6a43fd
runtime.call32(0x0, 0x7f9fb3f073f0, 0x7f9fb3f07480, 0x20)
	/usr/local/go/src/runtime/asm_amd64.s:539 +0x3b fp=0xc0048756e0 sp=0xc0048756b0 pc=0x45b1ab
runtime.cgocallbackg1(0x0)
	/usr/local/go/src/runtime/cgocall.go:314 +0x1b7 fp=0xc0048757c8 sp=0xc0048756e0 pc=0x4068c7
runtime.cgocallbackg(0x0)
	/usr/local/go/src/runtime/cgocall.go:191 +0xc1 fp=0xc004875830 sp=0xc0048757c8 pc=0x406671
runtime.cgocallback_gofunc(0x40653f, 0x6abcb0, 0xc0048758c0, 0xc0048758b0)
	/usr/local/go/src/runtime/asm_amd64.s:793 +0x9b fp=0xc004875850 sp=0xc004875830 pc=0x45c77b
runtime.asmcgocall(0x6abcb0, 0xc0048758c0)
	/usr/local/go/src/runtime/asm_amd64.s:640 +0x42 fp=0xc004875858 sp=0xc004875850 pc=0x45c612
runtime.cgocall(0x6abcb0, 0xc0048758c0, 0x7bfce5)
	/usr/local/go/src/runtime/cgocall.go:131 +0x7f fp=0xc004875890 sp=0xc004875858 pc=0x40653f
github.com/hillu/go-yara._Cfunc_yr_rules_scan_mem(0x1d1fff0, 0xc000b10000, 0x35a000, 0x1, 0x6ab390, 0x1d1f7e0, 0x5, 0x0)
	_cgo_gotypes.go:1524 +0x4d fp=0xc0048758c0 sp=0xc004875890 pc=0x6a3fcd
github.com/hillu/go-yara.(*Rules).ScanMemWithCallback.func1(0xc000094020, 0xc000b10000, 0xc000b10000, 0x35a000, 0x3ffe00, 0x1, 0x1d1f7e0, 0x12a05f200, 0x54869a)
	/go/src/github.com/hillu/go-yara/rules.go:91 +0xfc fp=0xc004875920 sp=0xc0048758c0 pc=0x6a8a0c
github.com/hillu/go-yara.(*Rules).ScanMemWithCallback(0xc000094020, 0xc000b10000, 0x35a000, 0x3ffe00, 0x1, 0x12a05f200, 0x6f6a20, 0xc000086080, 0x0, 0x0)
	/go/src/github.com/hillu/go-yara/rules.go:91 +0x1b7 fp=0xc004875a08 sp=0xc004875920 pc=0x6a6d37
github.com/hillu/go-yara.(*Rules).ScanMem(...)
	/go/src/github.com/hillu/go-yara/rules.go:68
main.ScanHandler(0x7cf660, 0xc0000bc0e0, 0xc0000f0100)
	/go/src/dockeryaramock/main.go:68 +0x167 fp=0xc004875ac8 sp=0xc004875a08 pc=0x6ab037
net/http.HandlerFunc.ServeHTTP(0x777918, 0x7cf660, 0xc0000bc0e0, 0xc0000f0100)
	/usr/local/go/src/net/http/server.go:2007 +0x44 fp=0xc004875af0 sp=0xc004875ac8 pc=0x656ef4
github.com/gorilla/mux.(*Router).ServeHTTP(0xc000044000, 0x7cf660, 0xc0000bc0e0, 0xc0000e0000)
	/go/src/github.com/gorilla/mux/mux.go:210 +0xe2 fp=0xc004875c18 sp=0xc004875af0 pc=0x69f8d2
net/http.serverHandler.ServeHTTP(0xc0000bc000, 0x7cf660, 0xc0000bc0e0, 0xc0000e0000)
	/usr/local/go/src/net/http/server.go:2802 +0xa4 fp=0xc004875c48 sp=0xc004875c18 pc=0x6595b4
net/http.(*conn).serve(0xc0000dc000, 0x7cfce0, 0xc00008a100)
	/usr/local/go/src/net/http/server.go:1890 +0x875 fp=0xc004875fc8 sp=0xc004875c48 pc=0x655f25
runtime.goexit()
	/usr/local/go/src/runtime/asm_amd64.s:1357 +0x1 fp=0xc004875fd0 sp=0xc004875fc8 pc=0x45cec1
created by net/http.(*Server).Serve
	/usr/local/go/src/net/http/server.go:2927 +0x38e

goroutine 1 [IO wait]:
internal/poll.runtime_pollWait(0x7f9fb1ec9f38, 0x72, 0x0)
	/usr/local/go/src/runtime/netpoll.go:184 +0x55
internal/poll.(*pollDesc).wait(0xc004868098, 0x72, 0x0, 0x0, 0x75f87b)
	/usr/local/go/src/internal/poll/fd_poll_runtime.go:87 +0x45
internal/poll.(*pollDesc).waitRead(...)
	/usr/local/go/src/internal/poll/fd_poll_runtime.go:92
internal/poll.(*FD).Accept(0xc004868080, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0)
	/usr/local/go/src/internal/poll/fd_unix.go:384 +0x1f8
net.(*netFD).accept(0xc004868080, 0xc004879d00, 0x65a0e4, 0xc0000bc0a0)
	/usr/local/go/src/net/fd_unix.go:238 +0x42
net.(*TCPListener).accept(0xc000086220, 0x5df0154c, 0xc004879d00, 0x4ac7d6)
	/usr/local/go/src/net/tcpsock_posix.go:139 +0x32
net.(*TCPListener).Accept(0xc000086220, 0xc004879d50, 0x18, 0xc000000180, 0x659a7e)
	/usr/local/go/src/net/tcpsock.go:261 +0x47
net/http.(*Server).Serve(0xc0000bc000, 0x7cf3e0, 0xc000086220, 0x0, 0x0)
	/usr/local/go/src/net/http/server.go:2896 +0x286
net/http.(*Server).ListenAndServe(0xc0000bc000, 0xc0000bc000, 0x1)
	/usr/local/go/src/net/http/server.go:2825 +0xb7
main.main()
	/go/src/dockeryaramock/main.go:52 +0x15c

goroutine 23 [IO wait]:
internal/poll.runtime_pollWait(0x7f9fb1ec9d98, 0x72, 0xffffffffffffffff)
	/usr/local/go/src/runtime/netpoll.go:184 +0x55
internal/poll.(*pollDesc).wait(0xc004868018, 0x72, 0x0, 0x1, 0xffffffffffffffff)
	/usr/local/go/src/internal/poll/fd_poll_runtime.go:87 +0x45
internal/poll.(*pollDesc).waitRead(...)
	/usr/local/go/src/internal/poll/fd_poll_runtime.go:92
internal/poll.(*FD).Read(0xc004868000, 0xc00007adc1, 0x1, 0x1, 0x0, 0x0, 0x0)
	/usr/local/go/src/internal/poll/fd_unix.go:169 +0x1cf
net.(*netFD).Read(0xc004868000, 0xc00007adc1, 0x1, 0x1, 0x0, 0x0, 0x0)
	/usr/local/go/src/net/fd_unix.go:202 +0x4f
net.(*conn).Read(0xc000094038, 0xc00007adc1, 0x1, 0x1, 0x0, 0x0, 0x0)
	/usr/local/go/src/net/net.go:184 +0x68
net/http.(*connReader).backgroundRead(0xc00007adb0)
	/usr/local/go/src/net/http/server.go:677 +0x58
created by net/http.(*connReader).startBackgroundRead
	/usr/local/go/src/net/http/server.go:673 +0xd4
