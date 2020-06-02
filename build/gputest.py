import tensorflow as tf
import numpy as np
import time


if __name__ == "__main__":
    N=1048576
    x = tf.constant(2.0*np.ones((N)),dtype=tf.float32)
    y = tf.constant(np.ones((N)),dtype=tf.float32)

    x_cpu=2.0*np.ones((N),dtype=np.float32)
    y_cpu=np.ones((N),dtype=np.float32)

    z=x+y
    with tf.Session() as sess:
        for _ in range(20):
            time1=time.time()
            out=sess.run(z)
            time2=time.time()
            print("GPU duration: =>", 1e6*(time2-time1))

            time1=time.time()
            # z_cpu=x_cpu+y_cpu
            y_cpu+=x_cpu
            time2=time.time()
            print("CPU duration: =>", 1e6*(time2-time1))




