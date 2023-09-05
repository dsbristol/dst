from functools import reduce
from multiprocessing import Pool, cpu_count, current_process
import datetime

def square(x):
    """Function to return the square of the argument"""
    # print("Worker %s calculating square of %s" % (current_process().pid, x))
    return x * x

if __name__ == "__main__":
    # print the number of cores
    begin_time = datetime.datetime.now()
    print("Number of cores available equals %s" % cpu_count())
    N=50
    #    N=10000000
    # create a pool of workers
    # start all worker processes
    pool = Pool(processes= cpu_count())
    # create an array of N integers, from 1 to N
    r = range(1, N+1)
    result = pool.map(square, r)

    total = reduce(lambda x, y: x + y, result)

    print("The sum of the square of the first %s integers is %s" % (N, total))
    end_time = datetime.datetime.now()
    print(end_time - begin_time)
