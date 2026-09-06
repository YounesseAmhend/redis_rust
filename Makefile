.PHONY: all tester test run clean \
	test-stage-1 test-stage-2 test-stage-3 test-stage-4 \
	test-stage-5 test-stage-6 test-stage-7 \
	test-base test-rdb test-aof test-repl test-streams \
	test-txn test-optimistic test-lists test-pubsub test-zset \
	test-bitmaps test-geo test-auth

ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
UNAME_S := $(shell uname -s)

# Official tester uses Unix process APIs. On Windows/Git Bash, run the same
# targets inside Ubuntu WSL.
ifeq ($(findstring Linux,$(UNAME_S))$(findstring Darwin,$(UNAME_S)),)

WSL_ROOT := /mnt$(shell cygpath -u "$(ROOT)")

all tester test run clean \
test-stage-1 test-stage-2 test-stage-3 test-stage-4 \
test-stage-5 test-stage-6 test-stage-7 \
test-base test-rdb test-aof test-repl test-streams \
test-txn test-optimistic test-lists test-pubsub test-zset \
test-bitmaps test-geo test-auth:
	MSYS_NO_PATHCONV=1 wsl -d Ubuntu -- bash "$(WSL_ROOT)/wsl-run.sh" make $@

else

TESTER_DIR := $(ROOT)/tester
TESTER_BIN := $(TESTER_DIR)/dist/main.out

STAGE_1 := {"slug":"jm1","tester_log_prefix":"stage-1","title":"Stage \#1: Bind to a port"}
STAGE_2 := {"slug":"rg2","tester_log_prefix":"stage-2","title":"Stage \#2: Respond to PING"}
STAGE_3 := {"slug":"wy1","tester_log_prefix":"stage-3","title":"Stage \#3: Respond to multiple PINGs"}
STAGE_4 := {"slug":"zu2","tester_log_prefix":"stage-4","title":"Stage \#4: Handle concurrent clients"}
STAGE_5 := {"slug":"qq0","tester_log_prefix":"stage-5","title":"Stage \#5: Implement the ECHO command"}
STAGE_6 := {"slug":"la7","tester_log_prefix":"stage-6","title":"Stage \#6: Implement the SET & GET commands"}
STAGE_7 := {"slug":"yz1","tester_log_prefix":"stage-7","title":"Stage \#7: Expiry"}

BASE_STAGES := [$(STAGE_1),$(STAGE_2),$(STAGE_3),$(STAGE_4),$(STAGE_5),$(STAGE_6),$(STAGE_7)]

RDB_STAGES := [{"slug":"zg5","tester_log_prefix":"stage-201","title":"Stage \#201: RDB Config"},{"slug":"jz6","tester_log_prefix":"stage-202","title":"Stage \#202: RDB Read Key"},{"slug":"gc6","tester_log_prefix":"stage-203","title":"Stage \#203: RDB String Value"},{"slug":"jw4","tester_log_prefix":"stage-204","title":"Stage \#204: RDB Read Multiple Keys"},{"slug":"dq3","tester_log_prefix":"stage-205","title":"Stage \#205: RDB Read Multiple String Values"},{"slug":"sm4","tester_log_prefix":"stage-206","title":"Stage \#206: RDB Read Value With Expiry"}]

AOF_STAGES := [{"slug":"uj3","tester_log_prefix":"stage-1101","title":"Default AOF options"},{"slug":"vd9","tester_log_prefix":"stage-1102","title":"AOF options from flags"},{"slug":"fm0","tester_log_prefix":"stage-1103","title":"Create append-only directory"},{"slug":"dw4","tester_log_prefix":"stage-1104","title":"Create append-only file"},{"slug":"pb9","tester_log_prefix":"stage-1105","title":"Create AOF manifest file"},{"slug":"dc8","tester_log_prefix":"stage-1106","title":"Write single command"},{"slug":"fi1","tester_log_prefix":"stage-1107","title":"Write multiple commands"},{"slug":"ep6","tester_log_prefix":"stage-1108","title":"Filter commands to write"},{"slug":"xz2","tester_log_prefix":"stage-1109","title":"Replay a single command"},{"slug":"kn2","tester_log_prefix":"stage-1110","title":"Replay multiple commands"}]

REPL_STAGES := [{"slug":"bw1","tester_log_prefix":"stage-101","title":"Stage \#101: Replication - Custom Port"},{"slug":"ye5","tester_log_prefix":"stage-102","title":"Stage \#102: Replication - Info on Master"},{"slug":"hc6","tester_log_prefix":"stage-103","title":"Stage \#103: Replication - Info on Replica"},{"slug":"xc1","tester_log_prefix":"stage-104","title":"Stage \#104: Replication - Replication ID and Offset"},{"slug":"gl7","tester_log_prefix":"stage-105","title":"Stage \#105: Replication - Handshake 1"},{"slug":"eh4","tester_log_prefix":"stage-106","title":"Stage \#106: Replication - Handshake 2"},{"slug":"ju6","tester_log_prefix":"stage-107","title":"Stage \#107: Replication - Handshake 3"},{"slug":"fj0","tester_log_prefix":"stage-108","title":"Stage \#108: Replication - REPLCONF"},{"slug":"vm3","tester_log_prefix":"stage-109","title":"Stage \#109: Replication - PSYNC"},{"slug":"cf8","tester_log_prefix":"stage-110","title":"Stage \#110: Replication - PSYNC w RDB file"},{"slug":"zn8","tester_log_prefix":"stage-111","title":"Stage \#111: Command Propagation"},{"slug":"hd5","tester_log_prefix":"stage-112","title":"Stage \#112: Command Propagation to multiple Replicas"},{"slug":"yg4","tester_log_prefix":"stage-113","title":"Stage \#113: Command Processing"},{"slug":"xv6","tester_log_prefix":"stage-114","title":"Stage \#114: GetAck with 0 offset"},{"slug":"yd3","tester_log_prefix":"stage-115","title":"Stage \#115: GetAck with non-0 offset"},{"slug":"my8","tester_log_prefix":"stage-116","title":"Stage \#116: WAIT with 0 replicas"},{"slug":"tu8","tester_log_prefix":"stage-117","title":"Stage \#117: WAIT with 0 offset"},{"slug":"na2","tester_log_prefix":"stage-118","title":"Stage \#118: WAIT Command"}]

STREAMS_STAGES := [{"slug":"cc3","tester_log_prefix":"stage-301","title":"Stage \#301: StreamsType"},{"slug":"cf6","tester_log_prefix":"stage-302","title":"Stage \#302: StreamsXadd"},{"slug":"hq8","tester_log_prefix":"stage-303","title":"Stage \#303: StreamsXaddValidateID"},{"slug":"yh3","tester_log_prefix":"stage-304","title":"Stage \#304: StreamsXaddPartialAutoid"},{"slug":"xu6","tester_log_prefix":"stage-305","title":"Stage \#305: StreamsXaddFullAutoid"},{"slug":"zx1","tester_log_prefix":"stage-306","title":"Stage \#306: StreamsXrange"},{"slug":"yp1","tester_log_prefix":"stage-307","title":"Stage \#307: StreamsXrangeMinID"},{"slug":"fs1","tester_log_prefix":"stage-308","title":"Stage \#308: StreamsXrangeMaxID"},{"slug":"um0","tester_log_prefix":"stage-309","title":"Stage \#309: StreamsXread"},{"slug":"ru9","tester_log_prefix":"stage-310","title":"Stage \#310: StreamsXreadMultiple"},{"slug":"bs1","tester_log_prefix":"stage-311","title":"Stage \#311: StreamsXreadBlock"},{"slug":"hw1","tester_log_prefix":"stage-312","title":"Stage \#312: StreamsXreadBlockNoTimeout"},{"slug":"xu1","tester_log_prefix":"stage-313","title":"Stage \#313: StreamsXreadBlockMaxID"}]

TXN_STAGES := [{"slug":"si4","tester_log_prefix":"stage-401","title":"Stage \#401: INCR-1"},{"slug":"lz8","tester_log_prefix":"stage-402","title":"Stage \#402: INCR-2"},{"slug":"mk1","tester_log_prefix":"stage-403","title":"Stage \#403: INCR-3"},{"slug":"pn0","tester_log_prefix":"stage-404","title":"Stage \#404: MULTI"},{"slug":"lo4","tester_log_prefix":"stage-405","title":"Stage \#405: EXEC"},{"slug":"we1","tester_log_prefix":"stage-406","title":"Empty Transaction"},{"slug":"rs9","tester_log_prefix":"stage-407","title":"Queueing Commands"},{"slug":"fy6","tester_log_prefix":"stage-408","title":"Executing a transaction"},{"slug":"rl9","tester_log_prefix":"stage-409","title":"Discarding a transaction"},{"slug":"sg9","tester_log_prefix":"stage-410","title":"Executing a failed transaction"},{"slug":"jf8","tester_log_prefix":"stage-411","title":"Executing concurrent transactions"}]

OPTIMISTIC_STAGES := [{"slug":"jb7","tester_log_prefix":"stage-1001","title":"The WATCH command"},{"slug":"jq9","tester_log_prefix":"stage-1002","title":"WATCH inside transaction"},{"slug":"mh8","tester_log_prefix":"stage-1003","title":"Tracking key modifications"},{"slug":"fp0","tester_log_prefix":"stage-1004","title":"Watching multiple keys"},{"slug":"uo9","tester_log_prefix":"stage-1005","title":"Watching missing keys"},{"slug":"bn1","tester_log_prefix":"stage-1006","title":"The UNWATCH command"},{"slug":"fn4","tester_log_prefix":"stage-1007","title":"Unwatch on EXEC"},{"slug":"hq1","tester_log_prefix":"stage-1008","title":"Unwatch on DISCARD"}]

LIST_STAGES := [{"slug":"mh6","tester_log_prefix":"stage-501","title":"Stage \#501: RPUSH-1"},{"slug":"tn7","tester_log_prefix":"stage-502","title":"Stage \#502: RPUSH-2"},{"slug":"lx4","tester_log_prefix":"stage-503","title":"Stage \#503: RPUSH-3"},{"slug":"sf6","tester_log_prefix":"stage-504","title":"Stage \#504: LRANGE-1"},{"slug":"ri1","tester_log_prefix":"stage-505","title":"Stage \#505: LRANGE-2"},{"slug":"gu5","tester_log_prefix":"stage-506","title":"Stage \#506: LPUSH"},{"slug":"fv6","tester_log_prefix":"stage-507","title":"Stage \#507: LLEN"},{"slug":"ef1","tester_log_prefix":"stage-508","title":"Stage \#508: LPOP-1"},{"slug":"jp1","tester_log_prefix":"stage-509","title":"Stage \#509: LPOP-2"},{"slug":"ec3","tester_log_prefix":"stage-510","title":"Stage \#510: BLPOP-1"},{"slug":"xj7","tester_log_prefix":"stage-511","title":"Stage \#511: BLPOP-2"}]

PUBSUB_STAGES := [{"slug":"mx3","tester_log_prefix":"stage-601","title":"Stage \#601: SUBSCRIBE-1"},{"slug":"zc8","tester_log_prefix":"stage-602","title":"Stage \#602: SUBSCRIBE-2"},{"slug":"aw8","tester_log_prefix":"stage-603","title":"Stage \#603: SUBSCRIBE-3"},{"slug":"lf1","tester_log_prefix":"stage-604","title":"Stage \#604: SUBSCRIBE-4"},{"slug":"hf2","tester_log_prefix":"stage-605","title":"Stage \#605: PUBLISH-1"},{"slug":"dn4","tester_log_prefix":"stage-606","title":"Stage \#606: PUBLISH-2"},{"slug":"ze9","tester_log_prefix":"stage-607","title":"Stage \#607: UNSUBSCRIBE"}]

ZSET_STAGES := [{"slug":"ct1","tester_log_prefix":"stage-701","title":"Stage \#701: ZADD-1"},{"slug":"hf1","tester_log_prefix":"stage-702","title":"Stage \#702: ZADD-2"},{"slug":"lg6","tester_log_prefix":"stage-703","title":"Stage \#703: ZRANK"},{"slug":"ic1","tester_log_prefix":"stage-704","title":"Stage \#704: ZRANGE-1"},{"slug":"bj4","tester_log_prefix":"stage-705","title":"Stage \#705: ZRANGE-2"},{"slug":"kn4","tester_log_prefix":"stage-706","title":"Stage \#706: ZCARD"},{"slug":"gd7","tester_log_prefix":"stage-707","title":"Stage \#707: ZSCORE"},{"slug":"sq7","tester_log_prefix":"stage-708","title":"Stage \#708: ZREM"}]

BITMAP_STAGES := [{"slug":"bq9","tester_log_prefix":"stage-bitmap-1","title":"Create a bitmap"},{"slug":"qj1","tester_log_prefix":"stage-bitmap-2","title":"Retrieve a bit"},{"slug":"yj2","tester_log_prefix":"stage-bitmap-3","title":"Read a string as bits"},{"slug":"pk5","tester_log_prefix":"stage-bitmap-4","title":"Read bits as a string"},{"slug":"yf6","tester_log_prefix":"stage-bitmap-5","title":"Grow a bitmap"},{"slug":"nx3","tester_log_prefix":"stage-bitmap-6","title":"Count set bits"},{"slug":"hv4","tester_log_prefix":"stage-bitmap-7","title":"AND two bitmaps"},{"slug":"dk2","tester_log_prefix":"stage-bitmap-8","title":"AND bitmaps of different lengths"},{"slug":"fr8","tester_log_prefix":"stage-bitmap-9","title":"OR two bitmaps"}]

GEO_STAGES := [{"slug":"zt4","tester_log_prefix":"stage-801","title":"Stage \#801: GEOADD-1"},{"slug":"ck3","tester_log_prefix":"stage-802","title":"Stage \#802: GEOADD-2"},{"slug":"tn5","tester_log_prefix":"stage-803","title":"Stage \#803: GEOADD-3"},{"slug":"cr3","tester_log_prefix":"stage-804","title":"Stage \#804: GEOADD-4"},{"slug":"xg4","tester_log_prefix":"stage-805","title":"Stage \#805: GEOPOS-1"},{"slug":"hb5","tester_log_prefix":"stage-806","title":"Stage \#806: GEOPOS-2"},{"slug":"ek6","tester_log_prefix":"stage-807","title":"Stage \#807: GEODIST"},{"slug":"rm9","tester_log_prefix":"stage-808","title":"Stage \#808: GEOSEARCH"}]

AUTH_STAGES := [{"slug":"jn4","tester_log_prefix":"stage-901","title":"Stage \#901: WHOAMI"},{"slug":"gx8","tester_log_prefix":"stage-902","title":"Stage \#902: ACL GETUSER-1"},{"slug":"ql6","tester_log_prefix":"stage-903","title":"Stage \#903: ACL GETUSER-2"},{"slug":"pl7","tester_log_prefix":"stage-904","title":"Stage \#904: ACL GETUSER-3"},{"slug":"uv9","tester_log_prefix":"stage-905","title":"Stage \#905: SET USER PASSWORD"},{"slug":"hz3","tester_log_prefix":"stage-906","title":"Stage \#906: THE AUTH COMMAND"},{"slug":"nm2","tester_log_prefix":"stage-907","title":"Stage \#907: ENFORCE AUTHENTICATION"},{"slug":"ws7","tester_log_prefix":"stage-908","title":"Stage \#908: AUTHENTICATE USING AUTH"}]

all: test

tester:
	mkdir -p "$(TESTER_DIR)/dist"
	go -C "$(TESTER_DIR)" build -o "$(TESTER_BIN)" ./cmd/tester

define run_tester
	CODECRAFTERS_SUBMISSION_DIR="$(ROOT)" \
	CODECRAFTERS_REPOSITORY_DIR="$(ROOT)" \
	CODECRAFTERS_TEST_CASES_JSON='$(1)' \
	"$(TESTER_BIN)"
endef

git:
	git add .
	git commit -m "$(m)"
	git push

# Empty JSON uses every stage from the official tester definition.
test: tester
	$(call run_tester,)

test-base: tester
	$(call run_tester,$(BASE_STAGES))

test-stage-1: tester
	$(call run_tester,[$(STAGE_1)])

test-stage-2: tester
	$(call run_tester,[$(STAGE_1),$(STAGE_2)])

test-stage-3: tester
	$(call run_tester,[$(STAGE_1),$(STAGE_2),$(STAGE_3)])

test-stage-4: tester
	$(call run_tester,[$(STAGE_1),$(STAGE_2),$(STAGE_3),$(STAGE_4)])

test-stage-5: tester
	$(call run_tester,[$(STAGE_1),$(STAGE_2),$(STAGE_3),$(STAGE_4),$(STAGE_5)])

test-stage-6: tester
	$(call run_tester,[$(STAGE_1),$(STAGE_2),$(STAGE_3),$(STAGE_4),$(STAGE_5),$(STAGE_6)])

test-stage-7: tester
	$(call run_tester,$(BASE_STAGES))

test-rdb: tester
	$(call run_tester,$(RDB_STAGES))

test-aof: tester
	$(call run_tester,$(AOF_STAGES))

test-repl: tester
	$(call run_tester,$(REPL_STAGES))

test-streams: tester
	$(call run_tester,$(STREAMS_STAGES))

test-txn: tester
	$(call run_tester,$(TXN_STAGES))

test-optimistic: tester
	$(call run_tester,$(OPTIMISTIC_STAGES))

test-lists: tester
	$(call run_tester,$(LIST_STAGES))

test-pubsub: tester
	$(call run_tester,$(PUBSUB_STAGES))

test-zset: tester
	$(call run_tester,$(ZSET_STAGES))

test-bitmaps: tester
	$(call run_tester,$(BITMAP_STAGES))

test-geo: tester
	$(call run_tester,$(GEO_STAGES))

test-auth: tester
	$(call run_tester,$(AUTH_STAGES))

run:
	./your_program.sh

clean:
	rm -rf "$(TESTER_DIR)/dist" target

endif
