# multi2boolean
A multilevel to Boolean gene regulatory network converter
* @author Shizuo KAJI
* @date 20 Jan. 2017
* @date updated on 24 Mar. 2017
* @copyright The MIT License

## A perl script to convert multilevel networks to Boolean networks
The algorithm is based on the paper
"A circuit-preserving mapping from multilevel to Boolean dynamics"
by A. Faure and S. Kaji
and
"On the conversion of multivalued gene regulatory networks to Boolean dynamics" 
by E. Tonello, arXiv:1703.06746

## How to use: 
- Define your model in the "Truth Table" (tt) format.
(GINSim can read and write tt files)
- For the Faure-Kaji algorithm
    perl multi2boolean.pl example.tt > out.tt
- For the Tonello algorithm
    perl multi2boolean.pl -t example.tt > out.tt
- the resulting out.tt is again in the Truth Table format.

## Truth Table (tt) format:
- (for details, please refer to the GINSim manual http://ginsim.org/ginsim-doc/current/format-truthtable.html )
- The first line contains a space/tab separated list of the names of the variables.
- The second to last lines consist of two columns separated by space/tab;
each line contains a source state followed by its corresponding target state.
(thus, the maximum value for each gene is restricted to 9)
