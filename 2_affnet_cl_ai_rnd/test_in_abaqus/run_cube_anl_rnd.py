import os
import subprocess
import numpy as np
import glob
import importlib
from itertools import product
from datetime import datetime
import shutil
import csv

class MaterialProperties:
    """
    - Manage material properties and their different configurations.
    - Generate material-related input files
    """

    def __init__(self, sim_dir, base_mat_props: dict, study_props: dict):
        self.sim_dir = sim_dir
        self.base_mat_props = base_mat_props
        self.study_props = study_props
        self.mat_configs = self._generate_material_configs()

    def _generate_material_configs(self):
        """Generate combinations/configurations of material properties"""
        aux_list = [self.study_props[key] for key in self.study_props]
        cross_props = list(product(*aux_list))
        return cross_props

    def get_material_props(self, config):
        """Material properties of a given configuration"""
        mat_props = self.base_mat_props.copy()
        for ikey, key in enumerate(self.study_props):
            mat_props[key] = config[ikey]
        return mat_props
    
    def write_mat_props_to_csv(self):
        file_names = ['base_mat_props.csv', 'study_props.csv']
        dicts = [self.base_mat_props, self.study_props]
        for i_file, file in enumerate(file_names):
            with open(os.path.join(self.sim_dir, file), 'w') as csv_file:  
                writer = csv.writer(csv_file)
                for key, value in dicts[i_file].items():
                    writer.writerow([key, value])
    
class AbaqusSimulation:
    """
    - Manage Abaqus simulations, from input creation to output extraction
    """

    def __init__(self, job_name='cube_anl_rnd', material_file='material_param.inp'):
        self.job_name = job_name
        self.material_file = material_file
        self.abq_extensions = ['.com', '.dat', '.msg', '.prt', '.sim', '.sta', '.odb', '.par']
    
    def delete_old_files(self):
        """Delete temp files and old odbs."""
        for ext in self.abq_extensions:
            files = glob.glob(f'{self.job_name}*{ext}')
            for file in files:
                try:
                    os.remove(file)
                except OSError as e:
                    print(f"Error deleting file {file}: {e}")
    
    def create_material_file(self, mat_props):
        """Create the material parameter inp file from given material properties."""
        with open(self.material_file, 'w') as file:
            file.write("*parameter\n")
            for key, value in mat_props.items():
                file.write(f"{key} = {value}\n")

    def create_section_file(self):
        command = ['/bin/python3.6', '-m', 'numpy.f2py', 
                   '-c', '-m', 'nsdvpy', 'sdv_py.f90']
        try:
            subprocess.run(command, check=True)
        except subprocess.CalledProcessError as e:
            print(f"An error occurred: {e}")
        import nsdvpy
        importlib.reload(nsdvpy)
        # Get number of SDVs
        nsdv = nsdvpy.sdv_read_py()
        # Create section input file
        filename = 'sec_anl_rnd.inp'
        with open(filename, 'w') as file:
            file.write('*Solid Section, elset=main_element, material=UD\n')
            # Write the Material Definition
            file.write('*Material, name=UD\n')
            file.write('*User Material, constants=14\n')
            file.write('<K>,<C10>,<C01>,<PHI>,<L>,<R0F>,<R0C>,<ETA>\n')
            file.write('<MU0>,<BETA>,<B0>,<LAMBDA0>,<NA>,<BDISP>\n')
            file.write('*DEPVAR\n')
            file.write(f'{nsdv},\n')
            file.write('1, DET, "DET"\n')
            if nsdv > 1:
                for i in range(2, nsdv+1):
                    file.write(f'{i}, ETAC{i-1}, "ETAC{i-1}"\n')
    
    def run_simulation(self):
        """Run Abaqus simulation."""
        try:
            subprocess.run(['abaqus', 'job=' + self.job_name + '.inp', 'user=umat_anl_ai_rnd.f', '-interactive'], check=True)
        except subprocess.CalledProcessError as e:
            print(f"Error running simulation: {e}")

    def extract_results(self):
        """Extract results with getoutput.py"""
        try:
            subprocess.run(['abaqus', 'cae', '-noGUI', 'getoutput.py'], check=True)
        except subprocess.CalledProcessError as e:
            print(f"Error extracting results: {e}")

    def move_results(self, base_dir, sim_dir, index):
        """ Move abaqus files and numpy outputs to sim directory """
        dest_path = os.path.join(sim_dir, str(index))
        files = glob.glob(f'*npy')
        os.makedirs(dest_path)
        for ext in self.abq_extensions:
            ext_files = glob.glob(f'{self.job_name}*{ext}')
            files.extend(ext_files)
        for file in files:
            filepath = os.path.join(base_dir, file)
            shutil.move(filepath, dest_path)
        

class SimulationManager:
    def __init__(self, base_mat_props, study_props):
        self.timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        self.base_dir = os.getcwd()
        self.sim_dir = os.path.join(self.base_dir, 'sim', self.timestamp)
        if not os.path.exists(self.sim_dir):
            os.makedirs(self.sim_dir)
        self.mat_props_manager = MaterialProperties(self.sim_dir, base_mat_props, study_props)
        self.simulation = AbaqusSimulation()
    
    def run_study(self):
        """Run the parametric study by looping through material configurations."""
        self.mat_props_manager.write_mat_props_to_csv()
        for c, config in enumerate(self.mat_props_manager.mat_configs):
            print(f"Running simulation for config {c}")
            mat_props = self.mat_props_manager.get_material_props(config)
        
            # Create input files and run simulation
            self.simulation.create_material_file(mat_props)
            self.simulation.create_section_file()
            self.simulation.delete_old_files()
            self.simulation.run_simulation()
            self.simulation.extract_results()
            self.simulation.move_results(self.base_dir, self.sim_dir, c)

if __name__ == "__main__":
    # Base Material Properties
    base_mat_props = {
        'density': 5.0e-4,
        'K': 1000.0,
        'C10': 0.0, 'C01': 0.0, 'PHI': 1.0,
        'L': 1.96, 'R0F': 1.63, 'R0C': 0.014,
        'ETA': 0.5, 'MU0': 1.0e9, 'BETA': 0.5, 
        'B0': 294.0 * 16.0 * 1.38065e-5, 'LAMBDA0': 1.0,
        'NA': 7.66, 'BDISP': 0.001
    }

    # Parameters to study
    study_props = {
        'ETA': [0.5]  # Add more parameters here if needed
    }

    # Initialize and run the simulation manager
    sim_manager = SimulationManager(base_mat_props, study_props)
    sim_manager.run_study()