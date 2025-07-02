#!/usr/bin/env python3
import numpy as np
from scipy.spatial import Delaunay
import trimesh
import open3d as o3d
import sys

# This script reads a point cloud from a file, performs Delaunay triangulation,
# and visualizes the mesh in 3D. It also exports the mesh to an .obj file.
#
# Example input file format:
# X Y Z
# 1.0 2.0 3.0
# 4.0 5.0 6.0

def load_points(file_path):
    cleaned = []
    with open(file_path, "r") as f:
        for line in f:
            if not line or "NaN" in line:
                continue
            values = list(map(float, line.split()))
            cleaned.append(values)
    return np.array(cleaned)

def delaunay_mesh(points):
    tri = Delaunay(points[:, :2]) 
    return tri

def mesh_to_obj(points, tri, filename="mesh.obj"):
    mesh = trimesh.Trimesh(vertices=points, faces=tri.simplices)
    mesh.export(filename)
    print(f"Exported mesh to {filename}")

def plot_with_open3d(points):
    pcd = o3d.geometry.PointCloud()
    pcd.points = o3d.utility.Vector3dVector(points)
    o3d.visualization.draw_geometries([pcd])

def save_to_file(file_path, points):
    file_path = file_path[:-4] + "_cleaned.txt" 
    np.savetxt(file_path, points, fmt="%.6f", delimiter="\t")
    print(f"Points saved to {file_path}")

def delaunay_to_open3d_mesh(points, tri):
    mesh = o3d.geometry.TriangleMesh()
    mesh.vertices = o3d.utility.Vector3dVector(points)
    mesh.triangles = o3d.utility.Vector3iVector(tri.simplices)
    mesh.compute_vertex_normals()
    return mesh

def str_to_bool(x):
    return str(x).strip().lower() in ("1", "true", "yes", "y")

def main(file_path, save_to_obj=False):
    points = load_points(file_path)
    save_to_file(file_path, points)
    tri = delaunay_mesh(points)
    mesh = delaunay_to_open3d_mesh(points, tri)
    if save_to_obj:
        mesh_to_obj(points, tri, filename="mesh.obj")
    o3d.visualization.draw_geometries([mesh])

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 clean_and_plot.py <txt_file> [save_to_obj]")
        sys.exit(1)

    file_path = sys.argv[1]
    save_to_obj = str_to_bool(sys.argv[2]) if len(sys.argv) > 2 else False

    main(file_path, save_to_obj)