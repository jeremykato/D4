require 'opencl_ruby_ffi'
require 'narray_ffi'

# This is an OpenCL Kernel program. That is to say, we feed this into a ruby
# function that compiles it into something that isn't gross.
source = <<EOF
__kernel void addition( __global const int *in, __global int *out) { \
  size_t i = get_global_id(0); \
  *out = (*out + in[i]) % 65336;\
} 
EOF

puts 'Starting...'

size = 500000000

# fill an array with random numbers. 
a_in = NArray.int(size).random(65536)
a_out = NArray.int(1)

# get the current computer's device context
platform = OpenCL::platforms.first
device = platform.devices.first
context = OpenCL::create_context(device)
queue = context.create_command_queue(device, :properties => OpenCL::CommandQueue::PROFILING_ENABLE)
# build opencl kernel
prog = context.create_program_with_source( source )
prog.build


b_in = context.create_buffer(a_in.size * a_in.element_size, :flags => OpenCL::Mem::COPY_HOST_PTR, :host_ptr => a_in)
b_out = context.create_buffer(a_out.size * a_out.element_size)

event = prog.addition(queue, [size], b_in, b_out, :local_work_size => [128])
queue.enqueue_read_buffer(b_out, a_out, :event_wait_list => [event])
queue.finish # don't advance till queue is done

puts 'Result: ' + a_out[0].to_s