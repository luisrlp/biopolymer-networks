############################################################################################################
'''
TO DO:
[essential]
- Allow defining properties for each direction or keep the same for all directions in a GP

[non-essential]
Define here the loading/boundary conditions for abaqus simulations

DONE:
- add the compilation of py/for files to build.py
- Change name of results dataframe columns
- Change format of df_results
Run abaqus simulations in test_in_abaqus folder
Change random variable/pdf definition within main if cycle (out of the classes or create class for random var assignment)
--Include gp level studies in the pipeline
--Information of the distribution of random inputs
--Save outputs (df) for gp studies
'''
############################################################################################################

import os
import subprocess
import numpy as np
import glob
import importlib
from itertools import product
from datetime import datetime
import shutil
import csv
import argparse
import pandas as pd
import json

import umatpy
from generator import Generator

class MaterialProperties:
    """
    - Manage material properties and their different configurations.
    - Generate material-related input files
    """

    def __init__(self, sim_dir, base_mat_props: dict, 
                 study_props: dict, study_props_info: dict = None):
        self.sim_dir = sim_dir
        self.base_mat_props = base_mat_props
        self.study_props = study_props
        self.study_props_info = study_props_info
        #self.mat_configs = self._generate_material_configs()

    def _generate_material_configs(self):
        """Not being used.
        Generate combinations/configurations of material properties"""
        aux_list = [self.study_props[key] for key in self.study_props]
        cross_props = list(product(*aux_list))
        return cross_props

    def get_material_props_old(self, config):
        """Not being used
        Material properties of a given configuration"""
        mat_props = self.base_mat_props.copy()
        for ikey, key in enumerate(self.study_props):
            mat_props[key] = config[ikey]
        return mat_props
    
    def get_material_props(self, iSample: int):
        """Material properties of a given configuration"""
        mat_props = self.base_mat_props.copy()
        for key, value in self.study_props.items():
            mat_props[key] = value[iSample]
        return mat_props
    
    def write_mat_props_to_csv(self):
        file_names = ['base_mat_props.csv', 'study_props_info.csv']
        dicts = [self.base_mat_props, self.study_props_info]
        for i_file, file in enumerate(file_names):
            with open(os.path.join(self.sim_dir, file), 'w') as json_file:
                json.dump(dicts[i_file], json_file, indent=4)
                # writer = csv.writer(json_file)
                # for key, value in dicts[i_file].items():
                #     writer.writerow([key, value])
    
class AbaqusSimulation:
    """
    - Manage Abaqus simulations, from input creation to output extraction
    """

    def __init__(self, job_name='cube_anl_mcs', material_file='material_param.inp', 
                 base_dir=None, abaqus_dir=None, sim_dir=None):
        self.job_name = job_name
        self.material_file = material_file
        self.base_dir = base_dir
        self.abaqus_dir = abaqus_dir
        self.sim_dir = sim_dir
        [self.nsdv, self.nelem, self.ndir, self.ngp] = globpy.global_read_py()
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

    def create_rnd_inp_file(self, mat_props):
        eta = mat_props['ETA']
        with open('etadir.inp', 'w') as inp_file:
            for el in range(1, self.nelem + 1):
                for gp in range(1, self.ngp + 1):
                    rnd_array = np.random.normal(eta, eta*0.1, self.ndir)
                    rnd_array = np.clip(rnd_array * (eta*self.ndir) / np.sum(rnd_array), 0, 1)
                    line = f"{el}, {gp}, " + ', '.join(f"{prop}" for prop in rnd_array) + '\n'
                    inp_file.write(line)

    def create_section_file(self):
        # Create section input file
        filename = 'sec_anl_mcs.inp'
        with open(filename, 'w') as file:
            file.write('*Solid Section, elset=main_element, material=UD\n')
            # Write the Material Definition
            file.write('*Material, name=UD\n')
            file.write('*User Material, constants=14\n')
            file.write('<K>,<C10>,<C01>,<PHI>,<L>,<R0F>,<R0C>,<ETA>\n')
            file.write('<MU0>,<BETA>,<B0>,<LAMBDA0>,<NA>,<BDISP>\n')
            file.write('*DEPVAR\n')
            file.write(f'{self.nsdv},\n')
            file.write('1, DET, "DET"\n')
            if self.nsdv > 1:
                for i in range(2, self.nsdv+1):
                    file.write(f'{i}, ETAC{i-1}, "ETAC{i-1}"\n')
    
    def run_simulation(self):
        """Run Abaqus simulation."""
        try:
            # Add gpu support
            subprocess.run(['abaqus', 'job=' + self.job_name + '.inp', 'user=umat_anl_ai_mcs.f', '-interactive'], check=True)
        except subprocess.CalledProcessError as e:
            print(f"Error running simulation: {e}")

    def extract_results(self):
        """Extract results with getoutput.py"""
        try:
            subprocess.run(['abaqus', 'cae', '-noGUI', 'getoutput.py'], check=True)
        except subprocess.CalledProcessError as e:
            print(f"Error extracting results: {e}")

    def move_results(self, index):
        """ Move abaqus (including random input) files and numpy outputs to sim directory """
        dest_path = os.path.join(self.sim_dir, str(index))
        files = glob.glob(f'*npy')
        os.makedirs(dest_path)
        for ext in self.abq_extensions:
            ext_files = glob.glob(f'{self.job_name}*{ext}')
            files.extend(ext_files)
        files.append('etadir.inp')
        for file in files:
            filepath = os.path.join(self.abaqus_dir, file)
            shutil.move(filepath, dest_path)
        
class RunUMAT:
    def __init__(self, def_info, sim_dir):
        self.sim_dir = sim_dir
        self.def_mode = def_info['def_mode']
        self.ramp_time = def_info['ramp_time']
        self.def_initial = def_info['def_initial']
        self.def_max = def_info['def_max']
        self.increments = def_info['increments']
        self.time_initial = def_info['time_initial']
        self.time_final = def_info['time_final']

    def deformation_gradient(self, deformation):
        """Computes the deformation gradient F for simple deformation modes
        INPUTS:
        - def_mode: deformation mode (str) - 'U', 'SSx', 'SSy' 
        - deformation: deformation [stretch, shear] value (float)
        OUTPUTS:
        - F: deformation gradient (np.array, 3x3)
        """
        if self.def_mode not in ['U', 'SSx', 'SSy']:
            raise ValueError("Invalid deformation mode. Choose 'U', 'SSx', or 'SSy'.")
        if not isinstance(deformation, (int, float)):
            raise TypeError("Stretch/shear value must be a number.")
        F = np.eye(3)
        if self.def_mode == 'U':
            F[0, 0] = deformation
            F[1, 1] = 1/np.sqrt(deformation)
            F[2, 2] = 1/np.sqrt(deformation)
        elif self.def_mode == 'SSx':
            F[0, 1] = deformation
        elif self.def_mode == 'SSy':
            F[1, 0] = deformation
        return F
    
    def ramp(self, time, ramp_time, def_initial, def_max):
        """Ramp function for deformation"""
        if time < ramp_time:
            return def_initial + (def_max - def_initial) * time / ramp_time
        else:
            return def_max

    def run_umat(self, mat_props):
        """Run UMAT with given deformation and ramp time."""
        time_array = np.linspace(self.time_initial, self.time_final, self.increments)
        dtime = time_array[1] - time_array[0]
        # s_xx = np.zeros((self.increments))
        # s_yy = np.zeros((self.increments))
        # s_zz = np.zeros((self.increments))
        # s_xy = np.zeros((self.increments))
        # s_shear = np.zeros((self.increments))
        # sef_array = np.zeros((self.increments))
        # def_array = np.zeros((self.increments))
        stress_array = np.zeros((self.increments, 6))
        sef_array = np.zeros(self.increments)
        def_array = np.zeros(self.increments)
        mat_props_list = [mat_props[key] for key in mat_props]
        for i, t in enumerate(time_array):
            deformation = self.ramp(t, self.ramp_time, self.def_initial, self.def_max)
            def_array[i] = deformation
            F = self.deformation_gradient(deformation)
            # Convert mat_props to list
            stress, sef = umatpy.run_umat_py(mat_props_list, 
                                             F, 
                                             [t, t + dtime], dtime, 
                                             i+1)
            sef_array[i] = sef
            if self.def_mode == 'SSx':
                stress[1] = stress[1] - stress[2]
                stress[2] = 0 # ????
            stress_array[i,:] = stress
            # if t == self.time_final:
            #     print(f"Stretch/shear: {deformation}")
            #     print(f"Final stress: {stress}")
            #     print(f"Final SEF: {sef}")
        return {'stress': np.array(stress_array),
                'sef': np.array(sef_array),
                'deformation': np.array(def_array),
                'time': np.array(time_array),
                }
    
    def save_results(self, results: pd.DataFrame, study_props: dict):
        """Save results to csv file"""
        # Add a column for each study property        
        for key, _ in study_props.items():
            results[key] = study_props[key]
        # Save results to a dataframe
        results = pd.DataFrame(results)
        # Save dataframe to pkl
        results.to_pickle(os.path.join(self.sim_dir, 'results.pkl'))
        

class SimulationManager:
    def __init__(self, base_mat_props: dict, study_props: dict, study_props_info: dict,
                 scale: str = None, def_info: dict = None,
                 n_samples: int = 1):
        self.scale = scale
        self.n_samples = n_samples
        self.timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        self.base_dir = os.getcwd()
        if self.scale == "element":
            self.abaqus_dir = os.path.join(self.base_dir, 'test_in_abaqus')
            self.sim_dir = os.path.join(self.abaqus_dir, 'sim', self.timestamp)
            self.simulation = AbaqusSimulation(job_name='cube_anl_mcs', 
                                            material_file='material_param.inp', 
                                            base_dir=self.base_dir, 
                                            abaqus_dir=self.abaqus_dir, 
                                            sim_dir=self.sim_dir)
        elif self.scale == "GP":
            self.sim_dir = os.path.join(self.base_dir, 'sim', self.timestamp)
            self.simulation = RunUMAT(def_info, self.sim_dir)
        # print(f"------------\nSimulation directory: {self.sim_dir}\n-------------")
        if not os.path.exists(self.sim_dir):
            os.makedirs(self.sim_dir)
        self.mat_props_manager = MaterialProperties(self.sim_dir, 
                                                    base_mat_props, 
                                                    study_props,
                                                    study_props_info)
    
    def run_study(self):
        """Run the parametric study by looping through material configurations."""
        self.mat_props_manager.write_mat_props_to_csv()
        if self.scale == "element":
            for c, config in enumerate(self.mat_props_manager.mat_configs):
                print(f"Running simulation for config {c}")
                mat_props = self.mat_props_manager.get_material_props(config)
                os.chdir(self.abaqus_dir)
                # Create input files and run simulation
                self.simulation.create_material_file(mat_props)
                self.simulation.create_rnd_inp_file(mat_props)
                self.simulation.create_section_file()
                self.simulation.delete_old_files()
                self.simulation.run_simulation()
                self.simulation.extract_results()
                self.simulation.move_results(c)
                os.chdir(self.base_dir)
                print(f"Simulation for config {c} completed.")
        elif self.scale == "GP":
            # Create empty dataframe for results
            df_results = pd.DataFrame()
            dict_results = {}
            for iSample in range(self.n_samples):
                print(f"Running simulation for sample {iSample}")
                mat_props = self.mat_props_manager.get_material_props(iSample)
                # os.chdir(self.sim_dir)
                # Run the UMAT
                iResults = self.simulation.run_umat(mat_props)
                # Add results dict to the empty dataframe
                dict_results[iSample] = iResults
                #df_results = pd.concat([df_results, pd.DataFrame([iResults])], axis=0, ignore_index=True)
                # self.simulation.create_material_file(mat_props)
                # self.simulation.create_rnd_inp_file(mat_props)
                # self.simulation.create_section_file()
                # self.simulation.delete_old_files()
                # self.simulation.run_simulation()
                # self.simulation.extract_results()
                # self.simulation.move_results(iSample)
                # os.chdir(self.base_dir)
                print(f"Simulation for sample {iSample} completed.")
            # Save results to csv
            df_results = pd.DataFrame.from_dict(dict_results, orient='index')
            self.simulation.save_results(df_results, self.mat_props_manager.study_props)
        print("Study completed.")


if __name__ == "__main__":

    # Script arguments
    parser = argparse.ArgumentParser(description='Run a parametric study of a material model in Abaqus.')
    parser.add_argument('--compile', type=bool, default=False, help='Whether to compile the UMAT.')
    parser.add_argument('--scale', type=str, default='GP', help='The scale of the study (element or GP).')
    parser.add_argument('--n_samples', type=int, default=5, help='The number of samples to generate.')
    parser.add_argument('--seed', type=int, default=0, help='The seed value for random number generation.')
    args = parser.parse_args()

    N_samples = args.n_samples
    seed = args.seed
    compile = args.compile
    scale  = args.scale

    # Globpy compilation
    if compile:
        command1 = ['/bin/python3.6', '-m', 'numpy.f2py', 
                    '-c', '-m', 'globpy', 'glb_py.f90']
        command2 = ['/bin/python3.6', '-m', 'numpy.f2py', 
                '-c', '-m', 'umatpy', 'py_anl_ai_mcs.f90', 'umat_anl_ai_mcs.f90']
        try:
            subprocess.run(command1, check=True)
        except subprocess.CalledProcessError as e:
            print(f"An error occurred: {e}")
    import globpy
    importlib.reload(globpy)
    importlib.reload(umatpy)

    # Base Material Properties
    base_mat_props = {
        'K': 1000.0,
        'C10': 1.0, 'C01': 1.0, 
        'PHI': 0.5, # Disable filament contribution by setting PHI to 0.0
        # 'L': 1.96, 'R0F': 1.63,
        'CACTIN': 9.5, 'R': 0.1, 
        'R0C': 0.014,
        'ETA': 0.5, 'MU0': 1.0e9, 'BETA': 0.5, 
        'B0': 294.0 * 16.0 * 1.38065e-5, 'LAMBDA0': 1.0,
        # 'NA': 7.66,
        'A': 1.2,
        'BDISP': 0.001
    }

    generator = Generator(seed=seed, size=N_samples)
    distributions = {
        'normal': generator.normal,
        'uniform': generator.uniform,
        'lognormal': generator.lognormal,
        'beta': generator.beta,
        'gamma': generator.gamma,
        'weibull': generator.weibull
    }    

    ''' Scale ["GP", "element"]''' 
    # GP: study umat response (Gauss Point level)
    # element: study response of a unit cube in abaqus (element level)

    ''' Approach ["deterministic", "random"] '''
    # "deterministic": same properties for all filament directions in a GP
    # "random": properties of each direction determined by a PDF
    approach = "deterministic"
    
    ''' Random Parameters '''
    study_props_info = {
        'C10': {'distribution': 'normal',
                'mean': 1.0,
                'std': 0.2},
        'C01': {'distribution': 'uniform',
                'low': 0.7,
                'high': 1.3},
        'CACTIN': {'distribution': 'normal',
                'mean': 9.5,
                'std': 1.5},
        'R': {'distribution': 'lognormal',
                'mean': 0.1,
                'std': 0.01},
        'R0C': {'distribution': 'normal',
                'mean': 0.014,
                'std': 0.003},
        'ETA': {'distribution': 'normal',
                'mean': 0.5,
                'std': 0.1},
        'BDISP': {'distribution': 'lognormal',
                'mean': 1.,
                'std': 0.01},
    }

    study_props = {key: distributions[value['distribution']](*list(value.values())[1:])
                for key, value in study_props_info.items()}

    '''Deformation info'''
    def_info = {
        'def_mode': 'SSx', # 'U', 'SSx', 'SSy'
        'def_initial': 0.0,
        'def_max': 0.2,
        'increments': 10,
        'time_initial': 0.0,
        'time_final': 1.0,
        'ramp_time': 1.0
    }


    # if approach == "deterministic":
    #     study_props = study_props_deterministic
    # elif approach == "random":
    #     study_props = study_props_random
    # else:
    #     raise ValueError("Approach not valid. Please choose 'deterministic' or 'random'.")

    # Initialize and run the simulation manager
    sim_manager = SimulationManager(base_mat_props,
                                    study_props,
                                    study_props_info,
                                    scale, 
                                    def_info,
                                    N_samples)
    sim_manager.run_study()