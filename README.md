# UMAT structure


## 1. _global_.f90
Sets the main control parameters to run the material-related routines (NELEM, NSDV, NTERM, NFACTOR).

--------------------------------------------------------------

## 2. _umat_.f90
- Main subroutine that imports _global_ parameters and organizes all secondary routines to fully describe the material behaviour.
- Header variables described in UMAT_README.txt.
- Initializes all variables as zero.

### _onem_
- Defines the 2nd and 4th order identity tensors and 4th order symmetric identity tensor: $\mathbf{I}, \mathbb{I}$ and $\mathbb{I}^s$, respectively. 
- $\mathbf{I}=\delta_{i j}\left(\mathbf{e}_i \otimes \mathbf{e}_j\right)$
- $\mathbb{I}=\delta_{i k} \delta_{j l}\left(\mathbf{e}_i \otimes \mathbf{e}_j \otimes \mathbf{e}_k \otimes \mathbf{e}_l\right)$
- $\mathbb{I}^s=\frac{1}{2}\left(\delta_{i k} \delta_{j l}+\delta_{i l} \delta_{j k}\right)\left(\mathbf{e}_i \otimes \mathbf{e}_j \otimes \mathbf{e}_k \otimes \mathbf{e}_l\right)$

**Material properties**: from array PROPS to scalar variable
1. k - Penalty parameter
2. c10 - Hyperelastic isotropic matrix constant 1
3. c01 - Hyperelastic isotropic matrix constant 2
4. phi - Filament volume fraction
5. ll - Filament contour length $(\mu \mathrm{m})$
6. r0f - Filament initial end-to-end distance $(\mu \mathrm{m})$
7. r0c - Crosslinker (CL) initial end-to-end distance $(\mu \mathrm{m})$
8. eta - CL relative stiffness
9. mu0 - Filament stretch modulus (pN)
10. beta - Beta parameter from Holzapfel beta model
11. b0 - Bending stiffness ($T \cdot L_p \cdot k_b$) (pN * $\mu \mathrm{m}^2$)
12. lambda0 - Pre-stretch
13. nn - Isotropic filaments per unit volume $(\mu \mathrm{m}^{-3})$
14. bb - Dispersion parameter

### _initialize_ and _sdvread_
- Initializes or reads state variables (determinant and contraction variance)

---------------------------------------------------------------

### 2.1. KINEMATICS

### _fslip_
- Computes volume-preserving/distortional part of the deformation gradient:
1. $J = \mathrm{det}(\mathbf{F})$
2. $\overline{\mathbf{F}} = J^{-1/3} \mathbf{F}$

### _matinv3d_
- This utility routine is used for computing $\mathbf{F}^{-1}$ and $\overline{\mathbf{F}}^{-1}$.

### _deformation_
- Computes right ($\mathbf{C}$) and left ($\mathbf{b}$) Cauchy-Green strain tensors, and their distortion parts.
- $\mathbf{C} = \mathbf{F}^\mathrm{T} \mathbf{F}$
- $\mathbf{b} = \mathbf{F} \mathbf{F}^\mathrm{T}$
- $\overline{\mathbf{C}} = \overline{\mathbf{F}}^\mathrm{T} \overline{\mathbf{F}}$
- $\overline{\mathbf{b}} = \overline{\mathbf{F}} \overline{\mathbf{F}}^\mathrm{T}$

### _invariants_
- Gets 1st and 2nd strain invariants ($\bar{I_i}$) [see Holzapfel 2000, 6.107-111]
- $\bar{I_1} = \mathrm{tr}\overline{\mathbf{C}} (= \mathrm{tr}\overline{\mathbf{b}})$
- $\bar{I_2} = \frac{1}{2}[(\mathrm{tr}\overline{\mathbf{C}})^2 - \mathrm{tr}(\overline{\mathbf{C}}^2)]$

### _stretch_
- Computes (deviatoric) stretch tensors $\overline{\mathbf{U}}$ and $\overline{\mathbf{v}}$. These tensors measure local stretching along their mutually orthogonal eigenvectors. Measure of local shape change.
- $\mathbf{U}$: Right (material) stretch tensor. Acts on the reference configuration. Its eigenvalues are the principal stretches. Shares eigenvectors ($\mathbf{\hat{N}}_a$) with $\mathbf{C}$.
- $\mathbf{v}$: Left (spatial) stretch tensor. Acts on the current configuration. Its eigenvalues are the principal stretches. Shares eigenvectors ($\mathbf{\hat{n}}_a$) with $\mathbf{b}$.
1. CALL _spectral_: ($\overline{\mathbf{C}}$) -> ($\Omega_a$ (eigenvalues = $\lambda_a^2$), $\mathbf{\hat{N}}_a$ (eigenvectors))
2. $\bar{\lambda}_a = \sqrt{\Omega_a}$
3. $\overline{\mathbf{U}}$ in the principal referential: $\overline{\mathbf{U}}_{aa}^{\mathrm{p}} = \bar{\lambda}_a$
4. $\overline{\mathbf{U}} = \mathbf{\hat{N}} \overline{\mathbf{U}}^{\mathrm{p}} \mathbf{\hat{N}}^{\mathrm{T}}$
- Repeat, using $\overline{\mathbf{b}}$ instead of $\overline{\mathbf{C}}$, to obtain $\overline{\mathbf{v}}$.

### _rotation_
- Calculates the rotation tensor: $\mathbf{R} = \overline{\mathbf{F}} \overline{\mathbf{U}}^{-1}$

------------------------------------------------------------------------------------------

### 2.2. CONSTITUTIVE RELATIONS

### _projeul_ and _projlag_
1. Projection tensor in Lagrangian (material) description: $\mathbb{P} = \mathbb{I} - (\mathbf{C}^{-1} \otimes \mathbf{C})/3$ (Falta dividir por 3 nos pngs do UMAT-Abaqus???)
2. Projection tensor in Eulerian (spatial) description: $\mathbb{p} = \mathbb{I}^s - (\mathbf{I} \otimes \mathbf{I})/3$

### _vol_
- Volumetric contribution of the strain energy function
1. $\mathcal{G}=\frac{1}{4}\left(J^2-1-2 \ln J\right)$
2. $\Psi_{\mathrm{vol}}=k \mathcal{G}$
3. $p^{*}=\frac{\mathrm{d} \Psi_{\text {vol }}(J)}{\mathrm{d} J} = \frac{1}{2}\kappa(J-J^{-1})$
4. $\tilde{p} = p^\* + J \frac{\mathrm{d}p^\*}{\mathrm{d}J}$

#### 2.2.1. Isotropic soft ground substance (IM)
- IM contribution is only considered when filament volume fration $\varphi<1$.

##### _isomat_
- IM strain energy and its derivatives (diso) in relation to the 5 invariants.
- $\Psi_{iso}=c_{10}(\bar{I_1}-3)+c_{01}(\bar{I_2}-3)$ (Mooney-Rivlin)
- diso $= \{c_{10}, c_{01}, 0, 0, 0\}$ 

##### _pk2isomatfic_
- 2nd Piola-Kirchoff fictitious stress tensor.
1. $\bar{\gamma}_1 = 2 \frac{ \partial \Psi\_{iso}\left(\bar{I}_1 ; \bar{I}_2\right)}{\partial \bar{I}_1} +\bar{I}_1 \frac{ \partial \Psi\_{iso}\left(\bar{I}_1 ; \bar{I}_2\right)}{\partial \bar{I}_2} = 2(\mathrm{diso}(1)+\bar{I}_1\mathrm{diso}(2))  $ 
2. $\bar{\gamma}\_2 = -2 \frac{\partial \Psi\_{\text {iso }}\left(\bar{I}_1 ; \bar{I}_2\right)}{\partial \bar{I}_2}=-2\mathrm{diso}(2)$
3. $\tilde{\mathbf{S}}=2 \frac{\partial \Psi_{\text {iso }}\left(\bar{I}_1 ; \bar{I}_2\right)}{\partial \overline{\mathbf{C}}}=\bar{\gamma}_1 \mathbf{I}+\bar{\gamma}_2 \overline{\mathbf{C}}$

##### _sigisomatfic_
- Cauchy fictitious stress tensor (push forward of $\tilde{\mathbf{S}}$)
- $\tilde{\mathbf{\sigma}} =J^{-1}  \mathbf{F} \tilde{\mathbf{S}} \mathbf{F}^{\mathrm{T}}$

##### _cmatisomatfic_
- 4th-order fictitious elasticity tensor in material description $\tilde{\mathbb{C}}$
- TO REVIEW (6.169 - Não falta multiplicar por J**-4/3?????)

##### _csisomatfic_
- 4th-order fictitious elasticity tensor in spatial description $\mathbb{\tilde{c}}$ (push-forward of $\tilde{\mathbb{C}}$)

#### 2.2.2. Filaments network (not implemented)

##### _erfi_
- Computes the imaginary error function.

#### 2.2.3. Affine network

##### _affclnetfic_discrete_
- Affine network with compliant crosslinkers. Returns the fictitious Cauchy $\tilde{\boldsymbol{\sigma}}$ and spatial elasticity $\tilde{\mathbb{c}}$ tensors.
- Detailed in AFFCLNETFIC_README.md

##### Adding affine, non-affine and isotropic matrix contributions, for both spatial and material descriptions
- $\tilde{\boldsymbol{\sigma}}=(1-\varphi)\tilde{\boldsymbol{\sigma}}\_{\mathrm{IM}} +\tilde{\boldsymbol{\sigma}}\_{\mathrm{NA}}+\tilde{\boldsymbol{\sigma}}_{\mathrm{AN}}$
- $\tilde{\mathbb{c}}=(1-\varphi)\tilde{\mathbb{c}}\_{\mathrm{IM}} +\tilde{\mathbb{c}}\_{\mathrm{NA}}+\tilde{\mathbb{c}}_{\mathrm{AN}}$
- $\tilde{\mathbf{S}} = (1-\varphi)\tilde{\mathbf{S}}\_{\mathrm{IM}} + \tilde{\mathbf{S}}\_{\mathrm{NA}}+\tilde{\mathbf{S}}_{\mathrm{AN}}$
- $\tilde{\mathbb{C}} = (1-\varphi)\tilde{\mathbb{C}}\_{\mathrm{IM}} + \tilde{\mathbb{C}}\_{\mathrm{NA}}+\tilde{\mathbb{C}}_{\mathrm{AN}}$

##### Strain-Energy (not computed)

### 2.3. Stress measures

#### 2.3.1. Volumetric

##### _pk2vol_
- Volumetric part of the second Piola-Kirchoff stress tensor
- $\mathbf{S}_{\mathrm{vol}} = J p^* \mathbf{C}^{-1}$ (nao falta multiplicar por J????)

##### _sigvol_
- Volumetric part of the Cauchy stress tensor
- $\mathbf{\sigma}_{\mathrm{vol}} = p^* \mathbf{I}$

#### 2.3.2. Isochoric

##### _pk2iso_
- Isochoric part of the second Piola-Kirchoff stress tensor
- $\overline{\mathbf{S}} = J^{-2/3} \mathbb{P} : \tilde{\mathbf{S}} $

##### _sigiso_
- Isochoric part of the Cauchy stress tensor ($\mathbb{p}$ is the eulerian projection tensor)
- $\overline{\mathbf{\sigma}} = \mathbb{p} : \tilde{\mathbf{\sigma}}$

##### Adding volumetric and isochoric contributions
- $\mathbf{S} = \mathbf{S}_{\mathrm{vol}} + \overline{\mathbf{S}}$
- $\mathbf{\sigma} = \mathbf{\sigma}_{\mathrm{vol}} + \overline{\mathbf{\sigma}}$

### 2.4. Elasticity tensors
- Computed in both spatial and material descriptions

#### Material (not implemented)

#### Spatial

##### _setvol_
- $\mathbb{c}_{\mathrm{vol}} = \tilde{p} \mathbf{I}\otimes\mathbf{I} - 2p^* \mathbb{I}^{\mathrm{s}}$

##### _setiso_
- $\bar{\mathbb{c}} = \mathbb{p}:\tilde{\mathbb{c}}:\mathbb{p} + \frac{2}{3}tr\tilde{\mathbf{\sigma}} - \frac{2}{3}(\overline{\mathbf{\sigma}}\otimes\mathbf{I} + \mathbf{I} \otimes \overline{\mathbf{\sigma}})$

##### _setjr_
- Computes the Jaumann rate
- $\mathbb{c}^{\mathrm{jr}} = \frac{1}{2}(\mathbf{\sigma}\otimes\mathbf{I} + \mathbf{I}\otimes\mathbf{\sigma})$

##### Adding all contributions
- $\mathbb{c} = \mathbb{c}_{\mathrm{vol}} + \bar{\mathbb{c}} + \mathbb{c}^{\mathrm{jr}}$

-----------------------------------------------------------------------------------------------------------------

## 3. _affclnetfic_discrete_

- Affine network with complaint crosslinkers
- Provides fictitious cauchy and elasticity tensors
- Discrete angular integration scheme (icosahedron)


### 3.1. Build the icosahedron

#### _icos_size_
- Sizes the 3D icosahedron
- Sets the number of points/vertices (12), edges (30), faces (20), points per face (3).

#### _icos_shape_
- Sets the icosahedron
1. Initiliaze 4 auxiliary variables for defining the icosahedron:
    - point_coord: array with the coordinates for each point 
    ```math 
    \begin{bmatrix}
    x_{1} & x_{2} & x_{3} \cdots \\
    y_{1} & y_{2} & y_{3} \cdots \\
    z_{1} & z_{2} & z_{3} \cdots
    \end{bmatrix}
    ```

    - edge_point: indices of the points that make up each edge
    ```math 
    \begin{bmatrix}
    1 & 1 & \cdots \\
    2 & 3 & \cdots
    \end{bmatrix}
    ```

    - face_order: npts in each face 
    ```math 
    \begin{bmatrix}
    3 & 3 & 3 & \cdots  
    \end{bmatrix}
    ```

    - face_point: indices of the points that make up each face
    ```math 
    \begin{bmatrix}
    1 & 1 & \cdots \\
    2 & 3 & \cdots \\
    3 & 4 & \cdots 
    \end{bmatrix}
    ```

2. Call _icos_shape_ to fill the 4 variables

### 3.2. Initialize model data
- Initialize integral data

#### Filament
- Read filament properties

#### Network
- Read network properties (including intitial preferred direction prefdir0)
- $r_0 = r_{0,f} + r_{0,c}$

##### _deffil_
- Gives the stretch and preferred direction in the deformed configuration
1. $m = \mathbf{F}m_0$
2. $\lambda = ||m||$

- Get the unit vector: $\hat{m} = \frac{m}{||m||}$

### 3.3. Angular Integration

- Loop through the faces of the icosahedron. For each face, go through the baricentric coordinates (f1, f2, f3) of all subtriangles. **Note:** Variable _factor_ defines how dense will be the subtriangle "mesh".

#### _sphere01_triangle_project_
- Calculates the unit sphere projection (x,y,z coordinates) of the center and vertices of the current subtriangle.

#### _sphere01_triangle_vertices_to_area_
- Calculates the area of the current **spherical** subtriangle, which will be used as a weight for the numerical integration.

#### _deffil_
- Stretch and preferred direction in the deformed configuration

#### _bangle_
- Angle between filament ($m_f$) and the preferred direction ($\hat{m}$)

#### _density_
- Filament density: $\rho = 4\sqrt{\frac{b}{2\pi}}\frac{\exp{2b{\cos{\theta}}^2}}{erfi}$

#### Filament and Crosslinker stretch
- $\lambda_f = \eta * \frac{r_0}{r_{0,f}}(\lambda-1)+1$
- $\lambda_c = (\lambda-r_0-\lambda_f*r_{0,f})/r_{0,c}$ (não é usado em lado nenhum???)

#### _fil_
- Call _pullforce_ to obtain the filament force
    - Gets the roots of $G(f)=0$. 
    - $G(f) = LHS-RHS = 0$ comes from the relation for extensible filaments: $\frac{\lambda \lambda_0 r_0}{L} = 1+\frac{f}{\mu_0} + \frac{(1+2f/\mu_0)(1+f/\mu_0)^\beta (1-r_0 / L)}{[1+fL^2/(\pi^2B_0)+f^2L^2/(\pi^2B_0\mu_0)]^\beta}$
- Filament Strain-Energy 1st and 2nd order derivatives
- $w' = \lambda_0 r_0 f$
- $w''=\frac{\lambda_{0}^{2} r_{0}^{2} \mu_{0} / L}{1+Y\left(\frac{1+\alpha f^{\*}}{1+f^{\*}+\alpha f^{*^{2}}}\right)^{\beta}\left(1-r_{0} / L\right)}$, with $Y=\frac{\beta}{\alpha} \frac{\left(1+2 \alpha f^{\star}\right)^{2}}{1+f^{\star}+\alpha f^{2}}-\beta \frac{1+2 \alpha f^{\star}}{1+\alpha f^{\star}}-2$

#### _sigfilfic_
- Fictitious Cauchy stress tensor 
- $\tilde{\boldsymbol{\sigma}}\_{\mathrm{AN}}=n J^{-1} \int_{\Omega} \left( \rho(\mathbf{m}) \hat{\bar{\lambda}}^{-1} \bar{w}^{\prime}(\widehat{\bar{\lambda}}) \mathbf{m} \otimes \mathbf{m} \right) d \Omega$

#### _csfilfic_
- Fictitious elasticity tensor (spatial description)
- $\widetilde{\mathbb{c}}\_{\mathrm{AN}}=n J^{-1} \int\_{\Omega} \rho(\mathbf{m}) \widehat{\bar{\lambda}}^{-2}\left[\bar{w}^{\prime \prime}(\widehat{\bar{\lambda}})-\widehat{\bar{\lambda}}^{-1} \bar{w}^{\prime}(\hat{\bar{\lambda}})\right] \mathbf{m} \otimes \mathbf{m} \otimes \mathbf{m} \otimes \mathbf{m} \mathrm{~d} \Omega$