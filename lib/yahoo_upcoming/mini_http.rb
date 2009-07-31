require 'socket'
require 'net/http'
require 'net/https'
require 'rack/utils' # For Rack::Utils.escape # TODO use C version? (evan/bougymans)

Net::HTTP.version_1_2 # Sorry if this causes anyone an issue...

module YahooUpcoming
  class MiniHttp

    # General exceptions which may be raised by Net::HTTP
    HttpExceptions = [
      Timeout::Error, EOFError, SystemCallError, SocketError,NoMemoryError,
      IOError, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError,
      Net::ProtocolError
    ]

    # The base_uri defines the full server uri path to which all #get and
    # #post calls will be made. The connection is lazy initialized but
    # persisted where possible. N.B. base_uri should contain the final
    # characters right up to where it would be appropraite to start query
    # parameters with "?". e.g.
    #   MiniHttp.new('http://upcoming.yahooapis.com/services/rest/')
    def initialize(base_uri)
      @base_uri = URI.parse(base_uri)
    end

    # Perform a simple GET at the @base_uri adding the params to the path if
    # given.
    def get(params = {})
      query = encode_params(params)
      query = "?#{query}" if query
      conn { |c| c.get("#{@base_uri.path}#{query}") }
    end

    # Perform a simple post at the @base_uri adding the params as POST
    # parameters.
    def post(params = {})
      query = encode_params(params)
      conn { |c| c.post @base_uri.path, query }
    end

    private
    # Splat a hash of params into a URI style query set, i.e.
    #   encode_params :a => 1, :b => 2 # => "a=1&b=2"
    def encode_params(params)
      params.map do |k,v|
        "#{Rack::Utils.escape k.to_s}=#{Rack::Utils.escape v.to_s}"
      end.join '&'
    end

    # Using the block form has the added advantage of catching the exceptions
    # that could be raised by Net::HTTP for you, otherwise you will have to 
    # handle those yourself.
    def conn
      @conn ||= connect
      if block_given?
        yield @conn
      else
        @conn
      end
    rescue *HttpExceptions
      @conn = nil
      retry if (retried = !retried)..retried
      # raise $! # XXX decide what to do here.. probably aggregate errors to a
      # single common failure.
    end

    # Just a wrapper around Net::HTTP.start effectively, but also sets up
    # use_ssl when necessary, based on the scheme in @base_uri.
    def connect
      http = Net::HTTP.new @base_uri.host, @base_uri.port
      http.use_ssl = @base_uri.scheme == 'https'
      http.start
      http
    end
    
    # Errnos that shouldn't ever be passed up to us, but could be - this is a
    # paranoia stack, for examples sake, not all necessary on all systems.
    # Common causes of these kinds of errors are adverse system load or
    # failing hardware. See errors.h on your platform for more details, or the
    # POSIX spec, or the BSD sockets api.
    HttpExceptions.concat [
      # Permission denied An attempt was made to access a file in a way
      # forbidden by its file access permissions.
      Errno::EACCES,      
      # Address in use The specified address is in use.
      Errno::EADDRINUSE,
      # Address not available The specified address is not available from the
      # local system.
      Errno::EADDRNOTAVAIL,
      # Address family not supported The implementation does not support the
      # specified address family, or the specified address is not a valid
      # address for the address family of the specified socket.
      Errno::EAFNOSUPPORT,
      # Resource temporarily unavailable This is a temporary condition and
      # later calls to the same routine may complete normally.
      Errno::EAGAIN,
      # Connection already in progress A connection request is already in
      # progress for the specified socket.
      Errno::EALREADY,
      # Bad file descriptor A file descriptor argument is out of range, refers
      # to no open file, or a read (write) request is made to a file that is
      # only open for writing (reading).
      Errno::EBADF,
      # Bad message During a read(), getmsg() or ioctl() I_RECVFD request to a
      # STREAMS device, a message arrived at the head of the STREAM that is
      # inappropriate for the function receiving the message.
      #   read() - message waiting to be read on a STREAM is not a data message.
      #   getmsg() - a file descriptor was received instead of a control message.
      #   ioctl() - control or data information was received instead of a file descriptor when I_RECVFD was specified.
      Errno::EBADMSG,
      # Resource busy An attempt was made to make use of a system resource
      # that is not currently available, as it is being used by another
      # process in a manner that would have conflicted with the request being
      # made by this process.
      Errno::EBUSY,
      # Operation canceled The associated asynchronous operation was canceled
      # before completion. Errno::ECANCELED, Connection aborted The connection
      # has been aborted.
      Errno::ECONNABORTED,
      # Connection refused An attempt to connect to a socket was refused
      # because there was no process listening or because the queue of
      # connection requests was full and the underlying protocol does not
      # support retransmissions.
      Errno::ECONNREFUSED,
      # Connection reset The connection was forcibly closed by the peer.
      Errno::ECONNRESET,
      # Posix?
      Errno::EHOSTDOWN,
      # Host is unreachable The destination host cannot be reached (probably
      # because the host is down or a remote router cannot reach it).
      Errno::EHOSTUNREACH,
      # Operation in progress This code is used to indicate that an
      # asynchronous operation has not yet completed.
      Errno::EINPROGRESS,
      # Invalid argument Some invalid argument was supplied; (for example,
      # specifying an undefined signal in a signal() function or a kill()
      # function).
      Errno::EINVAL,
      # Input/output error Some physical input or output error has occurred.
      # This error may be reported on a subsequent operation on the same file
      # descriptor. Any other error-causing operation on the same file
      # descriptor may cause the [EIO] error indication to be lost.
      Errno::EIO,
      # Too many open files An attempt was made to open more than the maximum
      # number of {OPEN_MAX} file descriptors allowed in this process.
      Errno::EMFILE,
      # Message too large A message sent on a transport provider was larger
      # than an internal message buffer or some other network limit.
      Errno::EMSGSIZE,
      # Network is down The local interface used to reach the destination is
      # down.
      Errno::ENETDOWN,
      # Posix?
      Errno::ENETRESET,
      # Network unreachable No route to the network is present.
      Errno::ENETUNREACH,
      # Too many files open in system Too many files are currently open in the
      # system. The system has reached its predefined limit for simultaneously
      # open files and temporarily cannot accept requests to open another one.
      Errno::ENFILE,
      # No buffer space available Insufficient buffer resources were available
      # in the system to perform the socket operation.
      Errno::ENOBUFS,
      # No message available No message is available on the STREAM head read
      # queue.
      Errno::ENODATA,
      # No locks available A system-imposed limit on the number of
      # simultaneous file and record locks has been reached and no more are
      # currently available.
      Errno::ENOLCK,
      # Not enough space The new process image requires more memory than is
      # allowed by the hardware or system-imposed memory management
      # constraints.
      Errno::ENOMEM,
      # Protocol not available The protocol option specified to setsockopt()
      # is not supported by the implementation.
      Errno::ENOPROTOOPT,
      # Socket not connected The socket is not connected.
      Errno::ENOTCONN,
      # Operation not supported on socket The type of socket (address family
      # or protocol) does not support the requested operation.
      Errno::EOPNOTSUPP,
      # Protocol error Some protocol error occurred. This error is device
      # specific, but is generally not related to a hardware failure.
      Errno::EPROTO,
      # Protocol not supported The protocol is not supported by the address
      # family, or the protocol is not supported by the implementation.
      Errno::EPROTONOSUPPORT,
      # Socket type not supported The socket type is not supported by the
      # protocol.
      Errno::EPROTOTYPE,
      # Result too large or too small The result of the function is too large
      # (overflow) or too small (underflow) to be represented in the available
      # space. (Defined in the ISO C standard.)
      Errno::ERANGE,
      # STREAM ioctl() timeout The timer set for a STREAMS ioctl() call has
      # expired. The cause of this error is device specific and could indicate
      # either a hardware or software failure, or a timeout value that is too
      # short for the specific operation. The status of the ioctl() operation
      # is indeterminate.
      Errno::ETIME,
      # Connection timed out The connection to a remote machine has timed out.
      # If the connection timed out during execution of the function that
      # reported this error (as opposed to timing out prior to the function
      # being called), it is unspecified whether the function has completed
      # some or all of the documented behaviour associated with a successful
      # completion of the function.
      Errno::ETIMEDOUT
    ]
  end
end