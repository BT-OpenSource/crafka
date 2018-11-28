lib LibC
  # need this for rd_kafka_dump()
  fun fdopen = fdopen(fd: Int32, mode: UInt8*) : Void*    # FILE *
end

@[Link("rdkafka")]
lib LibKafkaC

  # C API documented here:
  # https://github.com/edenhill/librdkafka/blob/master/src/rdkafka.h

  fun version = rd_kafka_version() : Int32
  fun version_str = rd_kafka_version_str() : UInt8*

  alias KafkaError = Int32
  alias KafkaHandle = Void*
  alias ConfHandle = Void *
  alias Topic = Void *
  alias TopicConf = Void *
  alias FileHandle = Void *  # TODO: already defined in LibC?
  alias MessagePtr = Void*
  alias QueueHandle = Void *
  alias QueueEvent = Void *
  alias EventType = Void *

  TYPE_PRODUCER = 0
  TYPE_CONSUMER = 1

  OK = 0

  MSG_FLAG_FREE = 0x1    # Delegate freeing of payload to rdkafka
  MSG_FLAG_COPY = 0x2    # rdkafka will make a copy of the payload.
  MSG_FLAG_BLOCK = 0x4   # Block produce*() on message queue full

  OFFSET_BEGINNING = -2_i64  # /**< Start consuming from beginning of
  OFFSET_END       = -1_i64  # /**< Start consuming from end of kafka

  RespErrAssignPartitions             = -175
  RespErrRevokePartitions             = -174
  PARTITION_UNASSIGNED = -1

  enum Event
    NONE = 0    # None
    DR = 1             # Producer Delivery report batch
    FETCH = 2          # Fetched message (consumer)
    LOG = 4            # Log message
    ERROR = 8          # Error
    REBALANCE = 10     # Group rebalance (consumer)
    OFFSET_COMMIT = 20 # Offset commit result
    STATS = 40
    CREATETOPICS_RESULT = 100
    DELETETOPICS_RESULT = 101
    CREATEPARTITIONS_RESULT = 102
    ALTERCONFIGS_RESULTS = 103
    DESCRIBECONFIGS_RESULT = 104
  end

  enum MessageTimestampType
    NOT_AVAILABLE
    CREATE_TIME
    LOG_APPEND_TIME
  end

  struct TopicPartition
    topic: Char*
    partition: Int32
    offset: Int64
    metadata: Void *
    metadata_size: LibC::SizeT
    opaque: Void *
    err: Int32
    _private: Void *
  end
  struct TopicPartitionList
    cnt: Int32
    size: Int32
    elems: TopicPartition*
  end

  struct Metadata
    broker_cnt: LibC::Int
    brokers: UInt8*
    topic_count: LibC::Int
    topics: Void*
    orig_broker_id: Int32
    orig_broker_name: Char*
  end


  enum VTYPE
    END = 0
    TOPIC = 1
    RKT = 2
    PARTITION = 3
    VALUE = 4
    KEY = 5
    OPAQUE = 6
    MSGFLAGS = 7
    TIMESTAMP = 8
    HEADER = 9
    HEADERS = 10
  end

struct Message
  err : Int32 #rd_kafka_resp_err_t err;   /**< Non-zero for error signaling. */
  rkt : Topic #rd_kafka_topic_t *rkt;     /**< Topic */
  partition : Int32 #int32_t partition;         /**< Partition */
  payload : UInt8* #void   *payload;           /**< Producer: original message payload.
          #* Consumer: Depends on the value of \c err :
          #* - \c err==0: Message payload.
          #* - \c err!=0: Error string */
  len : LibC::SizeT #size_t  len;               /**< Depends on the value of \c err :
          #* - \c err==0: Message payload length
          #* - \c err!=0: Error string length */
  key : UInt8* #void   *key;               /**< Depends on the value of \c err :
          #* - \c err==0: Optional message key */
  key_len : LibC::SizeT #size_t  key_len;           /**< Depends on the value of \c err :
          #* - \c err==0: Optional message key length*/
  offset : Int64 #int64_t offset;            /**< Consume:
          #    * - Message offset (or offset for error
          #*   if \c err!=0 if applicable).
  _priv : Void*
  timestamp : Int64
end

  fun conf_new = rd_kafka_conf_new : ConfHandle
  fun conf_destroy = rd_kafka_conf_destroy(conf: ConfHandle)
  fun conf_set = rd_kafka_conf_set(conf: ConfHandle, name: UInt8*, value: UInt8*, errstr: UInt8*, errstr_size: LibC::SizeT) : Int32

  fun conf_set_dr_msg_cb = rd_kafka_conf_set_dr_msg_cb(conf: ConfHandle, cb: (KafkaHandle, Void*, Void* ) -> )

  fun metadata = rd_kafka_metadata(h: KafkaHandle,
                                   all_topics: Int32,
                                   topic: Topic,
                                   metadata: Metadata**,
                                   timeout: Int32) : KafkaError
  fun metadata_destroy = rd_kafka_metadata_destroy(md: Metadata*)

  fun topic_conf_new = rd_kafka_topic_conf_new : TopicConf
  fun topic_conf_destroy = rd_kafka_topic_conf_destroy(tc : TopicConf)
  fun conf_set_default_topic_conf = rd_kafka_conf_set_default_topic_conf(conf: ConfHandle, tc: TopicConf) : Int32
  fun topic_conf_set = rd_kafka_topic_conf_set(tc: TopicConf, name: UInt8*, value: UInt8*, errstr: UInt8*, errstr_size: LibC::SizeT) : Int32

  fun topic_new = rd_kafka_topic_new(rk : KafkaHandle, topic_name : UInt8*, topic_conf : TopicConf) : Topic
  fun topic_destroy = rd_kafka_topic_destroy(t : Topic)
  fun topic_name = rd_kafka_topic_name(t: Topic) : UInt8*

  fun kafka_new = rd_kafka_new(t: Int32 , conf: ConfHandle, errstr: UInt8*, errstr_size: LibC::SizeT) : KafkaHandle
  fun kafka_destroy = rd_kafka_destroy(handle: KafkaHandle)

  fun produce = rd_kafka_produce(topic: Topic, partition: Int32, msgflags: Int32, payload: Void*, len: LibC::SizeT,
          key: Void*, keylen: LibC::SizeT, user_callback_arg: Void* ) : Int32

  fun producev = rd_kafka_producev(rk : KafkaHandle, ...  ) : Int32

  # returns 0 on success or -1 on error in which case errno is set accordingly:
  fun consume_start = rd_kafka_consume_start(topic: Topic, partition: Int32, offset: Int64) : Int32

  # returns 0 on success or -1 on error (see `errno`).
  fun consume_stop = rd_kafka_consume_stop(topic: Topic, partition: Int32) : Int32

  fun consume = rd_kafka_consume(topic: Topic, partition: Int32, timeout_ms: Int32) : Message*

  fun consumer_poll = rd_kafka_consumer_poll (rk: KafkaHandle, timeout_ms: Int32) : Message*
  fun poll_set_consumer = rd_kafka_poll_set_consumer (rk: KafkaHandle) : Int32
  fun brokers_add = rd_kafka_brokers_add(rk: KafkaHandle, broker_list: UInt8*) : Int32
  fun consumer_close = rd_kafka_consumer_close (rk: KafkaHandle) : Int32
  fun message_destroy = rd_kafka_message_destroy (msg: Message*)
  fun wait_destroyed = rd_kafka_wait_destroyed(timeout_ms: Int32) : Int32
  fun dump = rd_kafka_dump(file: FileHandle, rk: KafkaHandle)

  fun topic_partition_list_new = rd_kafka_topic_partition_list_new(size: Int32) : TopicPartitionList*
  fun topic_partition_list_add = rd_kafka_topic_partition_list_add(tplist: TopicPartitionList*, topic: UInt8*, partition: Int32) : Void* # TopicPartition
  fun topic_partition_list_destroy = rd_kafka_topic_partition_list_destroy(tplist: TopicPartitionList*)
  fun assign = rd_kafka_assign(rk: KafkaHandle, topics: TopicPartitionList*) : Int32


  fun poll = rd_kafka_poll(rk: KafkaHandle, timeout_ms: Int32) : Int32
  fun flush = rd_kafka_flush(rk: KafkaHandle, timeout_ms: Int32)

  fun queue_get_consumer = rd_kafka_queue_get_consumer(rk: KafkaHandle) : QueueHandle
  fun queue_get_main = rd_kafka_queue_get_main(rk: KafkaHandle) : QueueHandle
  fun queue_poll = rd_kafka_queue_poll(rkq: QueueHandle, timeout_ms: Int32) : QueueEvent
  fun event_type = rd_kafka_event_type(qe: QueueEvent) : Event
  fun event_error = rd_kafka_event_error(qe: QueueEvent) : Int32
  fun event_error_string = rd_kafka_event_error_string(qe: QueueEvent) : UInt8*
  fun event_message_next = rd_kafka_event_message_next(qe: QueueEvent) : Message*
  fun event_topic_partition_list = rd_kafka_event_topic_partition_list(ev : QueueEvent) : TopicPartitionList*
  fun message_timestamp = rd_kafka_message_timestamp(msg: Message*, t: MessageTimestampType*) : Int64

  fun last_error = rd_kafka_last_error() : Int32
  fun err2str = rd_kafka_err2str(code : Int32) : UInt8*

  fun conf_set_log_cb = rd_kafka_conf_set_log_cb(conf: ConfHandle, cb: (KafkaHandle, Int32, UInt32, UInt8*) -> )
  fun set_log_level = rd_kafka_set_log_level(kh: KafkaHandle, level: Int32)

  fun subscribe = rd_kafka_subscribe(handle: KafkaHandle, tpllist: TopicPartitionList*) : Int32
     fun set_rebalance_cb = rd_kafka_conf_set_rebalance_cb(conf : ConfHandle,
                                                           rebalance_cb : (KafkaHandle, Int32, TopicPartitionList*, Void* -> Void))
end
