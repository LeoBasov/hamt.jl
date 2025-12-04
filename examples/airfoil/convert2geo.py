import numpy as np
import matplotlib.pyplot as plt
import csv

def read_file(file_name):
    data = []
    
    with open(file_name) as file:
        read = csv.reader(file, delimiter=',')
        first = True
        
        for row in read:
            if first:
                first = False
                continue
            
            data.append(row)
            
    return data
            
def write_file(file_name, data):
    with open(file_name, "w+") as file:
        file.write("SetFactory(\"OpenCASCADE\");\n")
        
        for i in range(len(data)):
            point = data[i]
            file.write("Point({})".format(i + 1))
            file.write(" = {" + point[0] + ", " + point[1] + ", 0, 1.0" +  "};\n")
            
        for i in range(len(data)):
            file.write("Line({})".format(i + 1))
            file.write(" = {" + str(i + 1) + ", " + str(i + 2) + "};\n")
            
        file.write("Line(" + str(len(data) + 1) + ") = {" + str(len(data) + 1) + ", 1};\n")
            

if __name__ == '__main__':
    file_name = '/home/arwen/baso_le/GitHub/hamt.jl/examples/airfoil/NACA0012.csv'
    geo_file_name = '/home/arwen/baso_le/GitHub/hamt.jl/examples/airfoil/NACA0012.geo'
    data = read_file(file_name)
    write_file(geo_file_name, data)
    
    print('done')