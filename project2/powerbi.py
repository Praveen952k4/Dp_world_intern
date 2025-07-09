import psutil
import time 
import pyodbc
import socket
con = pyodbc.connect('Driver={SQL Server};'
                     'Server=192.168.89.198\\SQLEXPRESS;'
                     'Database=System_Information;'
                     'Trusted_Connection=yes;')

cursor = con.cursor()

while 1==1:
    cpu_usage = psutil.cpu_percent()
    memory_usage = psutil.virtual_memory()[2]
    cpu_interrupts = psutil.cpu_stats()[1]
    cpu_calls = psutil.cpu_stats()[3]
    memory_used = psutil.virtual_memory()[3]
    memory_free = psutil.virtual_memory()[4]
    bytes_sent = psutil.net_io_counters()[0]
    bytes_free = psutil.net_io_counters()[1]
    disk_usage = psutil.disk_usage('/').percent
    host_ip=socket.gethostname()

    cursor.execute('insert into Performance values (GETDATE(),'
               + str(cpu_usage)+ ','
               + str(memory_usage) + ','
               + str(cpu_interrupts) + ','
               + str(cpu_calls) + ','
               + str(memory_used) + ','
               + str(memory_free) + ','
               + str(bytes_sent) + ','
               + str(bytes_free) + ','
               + str(disk_usage) + ','
               + "'" + host_ip + "')") 
    
    con.commit()
    time.sleep(1)