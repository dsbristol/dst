import time
from multiprocessing import Pool, current_process

def slow_function(nsecs):
    """
    Function that sleeps for 'nsecs' seconds, returning
    the number of seconds that it slept
    """
    print("Process %s going to sleep for %s second(s)" % (current_process().pid, nsecs))
    # use the time.sleep function to sleep for nsecs seconds
    time.sleep(nsecs)
    print("Process %s waking up" % current_process().pid)
    return nsecs

if __name__ == "__main__":
    print("Master process is PID %s" % current_process().pid)

    with Pool(3) as pool:
        r = pool.map(slow_function, [8,2,3,4,5,6,7])

    print("Result is %s" % r)